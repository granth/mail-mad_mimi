require "madmimi"

module Mail
  class MadMimi
    class Error < StandardError; end
    attr_accessor :settings, :mimi

    def initialize(settings = {})
      unless settings[:email] && settings[:api_key]
        raise Error, "Missing :email and :api_key settings"
      end

      self.settings = settings
      self.mimi = ::MadMimi.new settings[:email], settings[:api_key]
    end

    def options_from_mail(mail)
      settings.merge(
        :recipients => mail[:to].to_s,
        :from       => mail[:from].to_s,
        :bcc        => mail[:bcc].to_s,
        :subject    => mail.subject
      ).tap do |options|
        options[:raw_html]       = mail.html_part.body.to_s if mail.html_part
        options[:raw_plain_text] = mail.text_part.body.to_s if mail.text_part

        if mail.respond_to? :mailer_action
          options[:promotion_name] = mail.mailer_action 
        end
      end
    end

    def deliver!(mail)
      mimi.send_mail(options_from_mail(mail), {}).tap do |response|
        raise Error, response if response.to_i.zero?  # no transaction id
      end
    end

    if defined? ActionMailer::Base
      ActionMailer::Base.add_delivery_method :madmimi, Mail::MadMimi

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
