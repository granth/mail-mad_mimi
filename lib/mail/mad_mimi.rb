require "madmimi"

module Mail #:nodoc:
  # Mail::MadMimi is a delivery method for <tt>Mail</tt>.
  # It uses the <tt>MadMimi</tt> library to send mail via Mad Mimi.
  #
  # = Headers and options
  #
  # The <tt>:to</tt>, <tt>:from</tt>, <tt>:bcc</tt>, and <tt>:subject</tt>
  # headers are taken from the <tt>Mail</tt> object passed to
  # <tt>deliver!</tt>
  #
  # In addition, any hash values given as a <tt>:mad_mimi</tt> header are
  # passed on to Mad Mimi. That means if you use the <tt>Mail</tt> object with
  # a different delivery method, you'll get an ugly <tt>mad_mimi</tt> header.
  #
  # You can see other available options on the Mad Mimi developer site:
  # http://madmimi.com/developer/mailer/transactional
  #
  # HTML (<tt>:raw_html</tt>) and plain text (<tt>:raw_plain_text</tt>) bodies
  # are extracted from the <tt>Mail</tt> object.
  #
  # Use <tt>:list_name => "beta users"</tt> to send to a list or
  # <tt>:to_all => true</tt> to send to all subscribers.
  #
  # = Rails 3 support
  #
  # If ActionMailer is loaded, Mail::MadMimi registers itself as a
  # delivery method.
  #
  # You can then configure it in an environment file:
  #
  #   config.action_mailer.delivery_method = :mad_mimi
  #   config.action_mailer.mad_mimi_settings = {
  #     :email   => "user@example.com",
  #     :api_key => "a1b9892611956aa13a5ab9ccf01f4966",
  #   }
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

        options.merge!(mail[:mad_mimi].value) if mail[:mad_mimi]
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
