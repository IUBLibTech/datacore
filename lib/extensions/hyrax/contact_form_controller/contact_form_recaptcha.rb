module Extensions
  module Hyrax
    module ContactFormController
      module ContactFormRecaptcha

        # modified from hyrax 2.9.6 with recaptcha check
        def create
          if !recaptcha_success?
            flash.now[:alert] = 'Please verify that you are not a robot.'
          # not spam and a valid form
          elsif @contact_form.valid?
            ::Hyrax::ContactMailer.contact(@contact_form).deliver_now
            flash.now[:notice] = 'Thank you for your message!'
            after_deliver
            @contact_form = ::Hyrax::ContactForm.new
          else
            flash.now[:error] = 'Sorry, this message was not sent successfully. '
            flash.now[:error] << @contact_form.errors.full_messages.map(&:to_s).join(", ")
          end
          render :new
        rescue ::RuntimeError => exception
          handle_create_exception(exception)
        end

        private
          # modified from hyrax 2.9.6 with recaptcha params
          def contact_form_params
            return {} unless params.key?(:contact_form)
            params.require(:contact_form).permit(:contact_method, :category, :name, :email, :subject, :message, 'g-recaptcha-response'.to_sym, 'g-recaptcha-response-data'.to_sym => [:contact_form])
          end

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
