# Mail::MadMimi

`Mail::MadMimi` is a delivery method for `Mail`.
It uses the `MadMimi` library to send mail via [Mad Mimi][1].

## Headers and options

The `:to`, `:from`, `:bcc`, and `:subject`
headers are taken from the `Mail` object passed to
`deliver!`

In addition, any hash values given as a `:mad_mimi` header are
passed on to Mad Mimi. That means if you use the `Mail` object with
a different delivery method, you'll get an ugly `mad_mimi` header.

You can see other available options on the [Mad Mimi developer site][2].

HTML (`:raw_html`) and plain text (`:raw_plain_text`) bodies are extracted
from the `Mail` object.

Use `:list_name => "beta users"` to send to a list or `:to_all => true`
to send to all subscribers.

## Mad Mimi macros

If you are sending to an individual email address, the body must
include `[[tracking_beacon]]` or `[[peek_image]]`.

If you are sending to a list or everyone, the body must include
`[[opt_out]]` or `unsubscribe`.

An exception will be raised if you don't include a macro. When debugging,
you may want to make sure that you set `raise_delivery_errors = true`
on your `Mail` object.

## Rails 3 support

If `ActionMailer` is loaded, `Mail::MadMimi` registers itself as a
delivery method.

You can then configure it in an environment file:

    config.action_mailer.delivery_method = :mad_mimi
    config.action_mailer.mad_mimi_settings = {
      :email   => "user@example.com",
      :api_key => "a1b9892611956aa13a5ab9ccf01f4966",
    }

[1]: http://madmimi.com
[2]: http://madmimi.com/developer/mailer/transactional
