module Extensions
  module HyraxExtensions
    module ContactFormController
      module ContactFormControllerBehavior

        def create
          if recaptcha_success?
            # not spam and a valid form
            if @contact_form.valid?
              Hyrax::ContactMailer.contact(@contact_form).deliver_now
              flash.now[:notice] = 'Thank you for your message!'
              after_deliver
              @contact_form = Hyrax::ContactForm.new
            else
              flash.now[:error] = 'Sorry, this message was not sent successfully. '
              flash.now[:error] << @contact_form.errors.full_messages.map(&:to_s).join(", ")
            end
          else
            flash.now[:alert] = 'Please verify that you are not a robot. '
          end

          render 'new'
        rescue RuntimeError => exception
          handle_create_exception(exception)
        end

        private

        def recaptcha_success?
          return true unless Settings.archive_api.use_recaptcha
          v3_success = verify_recaptcha(action: 'contact_form', minimum_score: Settings.recaptcha.minimum_score.to_f, secret_key: Settings.recaptcha.v3.secret_key)
          v2_success = verify_recaptcha unless v3_success
          v3_success || v2_success
        end
      end
    end
  end
end
