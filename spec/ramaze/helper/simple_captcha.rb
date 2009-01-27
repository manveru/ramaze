require 'spec/helper'

class SpecSimpleCaptcha < Ramaze::Controller
  helper :simple_captcha
  map '/'

  def ask_question
    question = simple_captcha
  end

  def answer_question(with)
    check_captcha(with) ? 'correct' : 'wrong'
  end
end

class SpecCustomCaptcha < SpecSimpleCaptcha
  map '/fish'

  trait :captcha => lambda{
    ["the answer to everything", 42]
  }
end

Innate.setup_dependencies

describe Ramaze::Helper::SimpleCaptcha do
  should 'ask question' do
    Ramaze::Mock.session do |session|
      question = session.get('/ask_question').body
      question.should =~ /^\d+ [+-] \d+$/

      lh, m, rh = question.split
      answer = lh.to_i.send(m, rh.to_i)

      session.get("/answer_question/#{answer}").body.should == 'correct'
    end
  end

  should 'ask custom question' do
    Ramaze::Mock.session do |session|
      question = session.get('/fish/ask_question')
      question.body.should == 'the answer to everything'
      session.get('/fish/answer_question/42').body.should == 'correct'
    end
  end
end
