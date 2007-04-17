#          Copyright (c) 2006 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

#Ramaze::Global.languages ||= {
#  :en => { :hello => 'Hello, World!' },
#  :de => { :hello => 'Hallo, Welt!' },
#}

class Ramaze::Tool::Localize

  # Enable Localization
  trait :enable => true

  # Default language that is used if the browser don't suggests otherwise or
  # the language requested is not available.
  trait :default_language => 'en'

  # languages supported
  trait :languages => %w[ en ]

  # YAML files the localizations are saved to and loaded from, %s is substituded
  # by the values from trait[:languages]
  trait :file => 'conf/locale_%s.yaml'.freeze

  # The pattern that is substituted with the translation of the current locale.
  trait :regex => /\[\[(.*?)\]\]/

  # Browsers may send different keys for the same language, this allows you to
  # do some coercion between what you use as keys and what the browser sends.
  trait :mapping => { 'en-us' => 'en', 'ja' => 'jp'}

  class << self

    include Ramaze::Trinity

    def call(response, options = {})
      return response unless trait[:enable]
      response.body = localize_body(response.body, options)
      response
    end

    def localize_body(body, options)
      body.gsub!(trait[:regex]) do
        localize($1)
      end

      body
    end

    def localize(str)
      locale = session[:LOCALE] || set_session_locale

      Ramaze::Inform.debug "localizing: #{locale} => '#{str}'"

      translate(locale, str)
    rescue ex
      Ramaze::Inform.error(ex)
      str
    end

    def translate(locale, str)
      trans = nil
      default_language = trait[:default_language]
      dict = dictionary

      if dict[locale] && trans = dict[locale][str]
        #
      elsif trans = dict[default_language][str]
        dict[locale][str] = str

        store(locale) # 'long' running operation
      else
        dict[locale][str] = str
        dict[default_language][str] = str

        store(locale, default_language) # 'long' running operation
      end

      trans || str
    end

    def set_session_locale
      session[:LOCALE] = trait[:default_language]
      accepted_languages = request.http_accept_language rescue nil

      return session[:LOCALE] unless accepted_languages

      mapping = trait[:mapping]
      dict = dictionary
      accepted_languages =
        accepted_languages.split(/[;,]/).delete_if {|l| l =~ /q=/ }

      accepted_languages.each do |language|
        language = mapping[language] || language
        if dict.has_key?(language)
          session[:LOCALE] = language
          break
        end
      end

      session[:LOCALE]
    end # end set_session_locale

    def dictionary
      trait[:dictionary] || load(*trait[:languages])
    end

    def load(*locales)
      Ramaze::Inform.debug "loading locales: #{locales.inspect}"

      dict = trait[:dictionary] || {}

      locales.each do |locale|
        dict[locale] = YAML.load_file(trait[:file] % locale)
      end

      trait[:dictionary] = dict
    end

    def store(*locales)
      locales.uniq.each do |locale|
        Ramaze::Inform.debug "saving localized to: #{trait[:file] % locale}"
        data = YAML::dump(dictionary[locale])
        file = trait[:file] % locale
        File.open(file, File::CREAT|File::TRUNC|File::WRONLY) do |fd|
          fd.write data
        end
      end
    end
  end
end
