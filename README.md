# Toones balance checker

- Toonesの残高をプログラムから確認し、特定の残高を下回ったらSlackへ通知をするスクリプトです。
- .envファイルにToonesにログインするためのメアドとパスワード、Slackへ通知するためのWebhookのURLを記載してください。

## setup
```
cp .env.template .env
vi .env
docker-compose build
```

## run
```
docker-compose up
```

## cron

example

```
10 9 * * * cd /foo/bar & docker-compose up > /tmp/toones.log
```

