#          Copyright (c) 2009 Michael Fellinger m.fellinger@gmail.com
# All files in this distribution are subject to the terms of the Ruby license.

require File.expand_path('../../../../spec/helper', __FILE__)
spec_require 'hpricot'

class SpecHelperPaginateArray < Ramaze::Controller
  map '/array'
  helper :paginate

  ALPHA = %w[ alpha beta gamma delta epsilon zeta eta theta iota kappa lambda
              mu nu xi omicron pi rho sigma tau ypsilon phi chi psi omega ]

  def navigation
    pager = paginate(ALPHA)
    pager.navigation
  end

  def iteration
    pager = paginate(ALPHA)
    out = []
    pager.each{|item| out << item }
    out.inspect
  end
end

describe Ramaze::Helper::Paginate do
  describe 'Array' do
    behaves_like :rack_test

    it 'shows navigation for page 1' do
      doc = Hpricot(get("/array/navigation").body)
      (doc/:a).map{|a| [a.inner_text, a[:href]] }.
        should == [
          ['1', '/array/navigation?pager=1'],
          ['2', '/array/navigation?pager=2'],
          ['3', '/array/navigation?pager=3'],
          ['>', '/array/navigation?pager=2'],
          ['>>', '/array/navigation?pager=3']]
    end

    it 'shows navigation for page 2' do
      doc = Hpricot(get("/array/navigation?pager=2").body)
      (doc/:a).map{|a| [a.inner_text, a[:href]] }.
        should == [
          ['<<', '/array/navigation?pager=1'],
          ['<', '/array/navigation?pager=1'],
          ['1', '/array/navigation?pager=1'],
          ['2', '/array/navigation?pager=2'],
          ['3', '/array/navigation?pager=3'],
          ['>', '/array/navigation?pager=3'],
          ['>>', '/array/navigation?pager=3']]
    end

    it 'shows navigation for page 3' do
      doc = Hpricot(get("/array/navigation?pager=3").body)
      (doc/:a).map{|a| [a.inner_text, a[:href]] }.
        should == [
          ['<<', '/array/navigation?pager=1'],
          ['<', '/array/navigation?pager=2'],
          ['1', '/array/navigation?pager=1'],
          ['2', '/array/navigation?pager=2'],
          ['3', '/array/navigation?pager=3']]
    end

    it 'iterates over the items in the pager' do
      got = get('/array/iteration')
      got.body.scan(/\w+/).should == SpecHelperPaginateArray::ALPHA.first(10)
    end
  end
end
