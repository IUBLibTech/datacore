module Extensions
  module Hyrax
    module ContactFormController
      module ContactFormRecaptcha

        # unmodified from hyrax 2.9.6
        def create
          # not spam and a valid form
          if @contact_form.valid?
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
          # unmodified from hyrax 2.9.6
          def contact_form_params
            return {} unless params.key?(:contact_form)
            params.require(:contact_form).permit(:contact_method, :category, :name, :email, :subject, :message)
          end
      end
    end
  end
end
