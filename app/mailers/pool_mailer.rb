class PoolMailer < ActionMailer::Base
  
  def send_pool_message(pool, subject, msg, allMembers)
    @pool = pool
    @msg = msg
    email_list = Array.new
    @pool.users.each do |user|
      if allMembers
        entries = Entry.where(pool_id: @pool.id, user_id: user.id)
      else
        entries = Entry.where(pool_id: @pool.id, user_id: user.id, survivorStatusIn:true)
      end
      if entries.any?
        email_list << "#{user.name} <#{user.email}>"
      end
    end
    subject_text = pool.name + "- " + subject
    user = pool.getOwner
    attachments.inline['fbpm_logo.png'] = {
                   data: File.read(Rails.root + "app/assets/images/fbpm_logo.png"),
                   mime_type: "image/png"
                }
    if mail to: email_list, from: "fbpoolmania@gmail.com", subject: subject_text
      return false
    else
      return true
    end
  end

  def send_pool_invite(pool, subject, msg, email_list)
    @pool = pool
    subject_text = pool.name + "- " + subject
    @msg = msg
    attachments.inline['fbpm_logo.png'] = {
                   data: File.read(Rails.root + "app/assets/images/fbpm_logo.png"),
                   mime_type: "image/png"
                }
    if mail to: email_list, from: "fbpoolmania@gmail.com", subject: subject_text
      return false
    else
      return true
    end
  end
end
