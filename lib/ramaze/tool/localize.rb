#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

$KCODE = 'UTF-8'
require 'ya2yaml'

# Localize helps transforming arbitrary text into localized forms using
# a simple regular expression and substituting occurences with predefined
# snippets stored in YAML files.
#
# == Usage:
#
#   Ramaze::Dispatcher::Action::FILTER << Ramaze::Tool::Localize

class Ramaze::Tool::Localize

  # Enable Localization
  trait :enable => true

  # Default language that is used if the browser don't suggests otherwise or
  # the language requested is not available.
  trait :default_language => 'en'

  # languages supported
  trait :languages => %w[ en ]

  # YAML files the localizations are saved to and loaded from, %s is
  # substituted by the values from trait[:languages]
  trait :file => 'conf/locale_%s.yaml'.freeze

  # The pattern that is substituted with the translation of the current locale.
  trait :regex => /\[\[(.*?)\]\]/

  # Browsers may send different keys for the same language, this allows you to
  # do some coercion between what you use as keys and what the browser sends.
  trait :mapping => { 'en-us' => 'en', 'ja' => 'jp'}

  # When this is set to false, it will not save newly collected translatable
  # strings to disk.  Disable this for production use, as it slows the
  # application down.
  trait :collect => true

  class << self

    include Ramaze::Trinity

    # Enables being plugged into Dispatcher::Action::FILTER

    def call(response, options = {})
      return response unless trait[:enable]
      return response if response.body.nil?
      return response if response.body.respond_to?(:read)
      response.body = localize_body(response.body, options)
      response
    end

    # Localizes a response body.  It reacts to a regular expression as given
    # in trait[:regex].  Every 'entity' in it will be translated, see
    # `localize` for more information.

    def localize_body(body, options)
      locale = (session[:LOCALE] || set_session_locale).to_s

      body.gsub!(trait[:regex]) do
        localize($1, locale) unless $1.to_s.empty?
      end

      store(locale, trait[:default_language]) if trait[:collect]

      body
    end

    # Localizes a single 'entity'.  If a translation in the chosen language is
    # not available, it falls back to the default language.

    def localize(str, locale)
      trans = nil
      default_language = trait[:default_language]
      dict = dictionary

      if dict[locale] && trans = dict[locale][str]
        #
      elsif dict[default_language] && trans = dict[default_language][str]
        dict[locale] ||= {}
        dict[locale][str] = str
      else
        dict[locale] ||= {}
        dict[default_language] ||= {}
        dict[locale][str] = str
        dict[default_language][str] = str
      end

      trans || str
    rescue Object => ex
      Ramaze::Inform.error(ex)
      str
    end

    # Sets session[:LOCALE] to one of the languages defined in the dictionary.
    # It first tries to honor the browsers accepted languages and then falls
    # back to the default language.

    def set_session_locale
      session[:LOCALE] = trait[:default_language]
      accepted_langs = request.http_accept_language rescue 'en'

      mapping = trait[:mapping]
      dict = dictionary
      accepted_langs = accepted_langs.scan(/([^,;]+)(?:;q=[^,]+)?/m)[0]

      accepted_langs.each do |language|
        language = mapping[language] || language
        if dict.key?(language)
          session[:LOCALE] = language
          break
        end
      end

      session[:LOCALE]
    end

    # Returns the dictionary used for translation.

    def dictionary
      trait[:languages].map! {|x| x.to_s }.uniq!
      trait[:dictionary] || load(*trait[:languages])
    end

    # Load given locales from disk and save it into the dictionary.

    def load(*locales)
      Ramaze::Inform.debug "loading locales: #{locales.inspect}"

      dict = trait[:dictionary] || {}

      locales.each do |locale|
        begin
          dict[locale] = YAML.load_file(trait[:file] % locale)
        rescue Errno::ENOENT
          dict[locale] = {}
        end
      end

      trait[:dictionary] = dict
    end

    # Stores given locales from the dictionary to disk.

    def store(*locales)
      locales.uniq.compact.each do |locale|
        Ramaze::Inform.dev "saving localized to: #{trait[:file] % locale}"
        data = dictionary[locale].ya2yaml
        file = trait[:file] % locale
        File.open(file, File::CREAT|File::TRUNC|File::WRONLY) do |fd|
          fd.write data
        end
      end
    rescue Errno::ENOENT => e
      Ramaze::Inform.error e
    end
  end
end
