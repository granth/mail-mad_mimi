require "action_mailer"
require "spec_helper"

class TestMailer < ActionMailer::Base
  def testo
    mail :to => "testo@example.com"
  end
end

describe Mail::MadMimi, "when ActionMailer is loaded" do
  it "should register itself as a delivery_method" do
    ActionMailer::Base.delivery_methods[:madmimi].should == Mail::MadMimi
  end

  it "should add a mailer_action method to messages for the promotion name" do
    TestMailer.testo.mailer_action.should == "TestMailer.testo"
  end
end
