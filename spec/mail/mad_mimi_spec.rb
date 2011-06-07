require "spec_helper"

describe Mail::MadMimi do
  let(:required_settings) { {:email => "joe@example.com", :api_key => "123"} }

  context "when created without an email address or API key" do
    it "should raise an error" do
      expect { Mail::MadMimi.new }.to raise_error Mail::MadMimi::Error
    end
  end

  context "when created with an email address and API key" do
    subject { Mail::MadMimi.new required_settings }

    it "should pass the email address and API key to MadMimi" do
      subject.mimi.should be_a ::MadMimi
      subject.mimi.username.should == "joe@example.com"
      subject.mimi.api_key.should  == "123"
    end

    it "should have a settings accessor" do
      subject.settings.should == required_settings
    end
  end

  context "getting options from a Mail::Message" do
    subject { Mail::MadMimi.new required_settings }

    let(:mail) do
      Mail.new do
        to      "Andrew <andrew@example.com>"
        from    "Bob <bob@example.com>"
        bcc     "charlie@example.com"
        subject "test mail"
      end
    end

    let(:options) { subject.options_from_mail(mail) }

    it "should create a hash of options" do
      options[:recipients].should == "Andrew <andrew@example.com>"
      options[:from].should       == "Bob <bob@example.com>"
      options[:bcc].should        == "charlie@example.com"
      options[:subject].should    == "test mail"
    end

    it "should merge in the class settings" do
      subject.settings[:hidden] = true  # hide in Mad Mimi interface
      options[:hidden].should be_true
    end

    it "should merge in :mad_mimi settings in mail object" do
      mail[:mad_mimi] = {:promotion_name => "custom"}
      options[:promotion_name].should == "custom"
    end

    context "with a text part" do
      before(:each) do
        mail.text_part do
          body "text body"
        end
      end

      it "should set :raw_plain_text" do
        options[:raw_plain_text].should == "text body"
      end

      it "should not set :raw_html to ensure plain text from Mad Mimi" do
        options.should_not have_key :raw_html
      end
    end

    context "with a non-multipart text body" do
      before(:each) do
        mail.body         = "text body"
        mail.content_type = "text/plain"
      end

      it "should set :raw_plain_text" do
        options[:raw_plain_text].should == "text body"
      end
    end

    context "with a text body no content type given" do
      before(:each) do
        mail.body = "text body"
      end

      it "should set :raw_plain_text" do
        options[:raw_plain_text].should == "text body"
      end
    end

    context "with an HTML part" do
      before(:each) do
        mail.html_part do
          content_type "text/html"
          body         "html body"
        end
      end

      it "should set :raw_html" do
        options[:raw_html].should == "html body"
      end
    end

    context "with a non-multipart HTML body" do
      before(:each) do
        mail.body         = "html body"
        mail.content_type = "text/html"
      end

      it "should set :raw_html" do
        options[:raw_html].should == "html body"
      end
    end

    context "with a mailer_action method" do
      before(:each) do
        mail.stub :mailer_action => "Mailer.method"
      end

      it "should set the promotion name" do
        options[:promotion_name].should == "Mailer.method"
      end
    end
  end

  context "delivering" do
    subject { Mail::MadMimi.new required_settings }

    let(:mail) do
      Mail.new do
        to      "Andrew <andrew@example.com>"
        from    "bob@example.com"
        bcc     "charlie@example.com"
        subject "test mail"
      end
    end

    let(:options) { subject.options_from_mail mail }

    before(:each) do
      subject.mimi.stub :send_mail => "1234"  # returns transaction id
    end

    it "should call MadMimi#send_mail" do
      subject.mimi.should_receive(:send_mail).with(options, {})
      subject.deliver! mail
    end

    it "should return the transaction id" do
      subject.deliver!(mail).should == "1234"
    end

    context "with an error response" do
      before(:each) do
        subject.mimi.stub :send_mail => "oh no"
      end

      it "should raise the error" do
        expect { subject.deliver! mail }.
          to raise_error Mail::MadMimi::Error, "oh no"
      end
    end
  end
end
