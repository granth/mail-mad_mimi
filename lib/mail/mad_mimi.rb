require "madmimi"

module Mail #:nodoc:
  # Mail::MadMimi is a delivery method for <tt>Mail</tt>.
  # It uses the <tt>MadMimi</tt> library to send mail via Mad Mimi.

  class MadMimi
    class Error < StandardError; end
    attr_accessor :settings, :mimi

    # Any settings given here will be passed to Mad Mimi.
    #
    # <tt>:email</tt> and <tt>:api_key</tt> are required.
    def initialize(settings = {})
      unless settings[:email] && settings[:api_key]
        raise Error, "Missing :email and :api_key settings"
      end

      self.settings = settings
      self.mimi = ::MadMimi.new settings[:email], settings[:api_key]
    end

    def options_from_mail(mail)
      settings.merge(
        :recipients     => mail[:to].to_s,
        :from           => mail[:from].to_s,
        :bcc            => mail[:bcc].to_s,
        :subject        => mail.subject,
        :raw_html       => html(mail),
        :raw_plain_text => text(mail)
      ).tap do |options|
        if mail.respond_to? :mailer_action
          options[:promotion_name] = mail.mailer_action
        end

        options.merge!(mail[:mad_mimi].value) if mail[:mad_mimi]

        options.reject! {|k,v| v.nil? }
      end
    end

    def html(mail)
      body(mail, "text/html")
    end

    def text(mail)
      body(mail, "text/plain") || mail.body.to_s
    end

    def body(mail, mime_type)
      if part = mail.find_first_mime_type(mime_type)
        part.body.to_s
      elsif mail.mime_type == mime_type
        mail.body.to_s
      end
    end

    def deliver!(mail)
      mimi.send_mail(options_from_mail(mail), {}).tap do |response|
        raise Error, response if response.to_i.zero?  # no transaction id
      end
    end

    if defined? ActionMailer::Base
      ActionMailer::Base.add_delivery_method :mad_mimi, Mail::MadMimi

      module SetMailerAction
        def wrap_delivery_behavior!(*args)
          super
          message.class_eval { attr_accessor :mailer_action }
          message.mailer_action = "#{self.class}.#{action_name}"
        end
      end
      ActionMailer::Base.send :include, SetMailerAction
    end
  end
end
