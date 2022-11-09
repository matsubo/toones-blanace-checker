require 'bundler/setup'
Bundler.require

require 'json'

Dotenv.load

mail     = ENV.fetch('EMAIL')
password = ENV.fetch('PASSWORD')
request_url = ENV.fetch('SLACK_WEBHOOK_URL')

logger = Logger.new($stdout)

begin
  agent = Mechanize.new
  agent.max_history = 2
  agent.user_agent_alias = 'Mac Firefox'
  agent.conditional_requests = false

  login_page = agent.get('https://my.toones.jp/logins/')

  logger.debug(login_page.title)

  login_form = login_page.form_with(id: 'LoginsCheckForm')

  logger.debug login_form

  login_form.field_with(id: 'CustomerMail').value = mail
  login_form.field_with(id: 'CustomerPassword').value = password

  logger.debug login_form

  top_page = login_form.submit

  logger.debug(top_page.title)

  my_page = agent.get('https://my.toones.jp/')
  balance_element = my_page.search('//*[@id="str-primary"]/section[1]/table/tbody/tr/td')

  balance = balance_element.inner_text.delete('^0-9').to_i

  logger.info(balance)

  if balance < 5000

    text = "残高が少なくなりました。#{balance}pt。<https://my.toones.jp/|こちら>から残高を追加してください。"
    color = 'warning'

    color = 'danger' if balance < 2000

    data = {
      attachments: [
        {
          "username": 'Toones balance checker',
          "fallback": text,
          "color": color,
          "fields": [
            {
              "title": 'Toones残高',
              "value": text,
              "short": false
            }
          ]
        }
      ]
    }

    Net::HTTP.post_form(URI.parse(request_url), { 'payload' => data.to_json })
  end

  logout_page = agent.get('https://my.toones.jp/tops/logout')

  logger.debug(logout_page.title)

rescue => e
  logger.error e.to_s
  Net::HTTP.post_form(URI.parse(request_url), { payload: { text: e.to_s }.to_json })
end

