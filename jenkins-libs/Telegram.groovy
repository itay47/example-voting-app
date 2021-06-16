// this is a Telegram sender module
// How to build jenkins libraries:
//   https://medium.com/android-news/how-to-build-libraries-for-jenkins-pipelines-1772aa0da53d
// How to integrate Telegram with jenkins:
//   https://medium.com/android-news/integrate-jenkins-with-telegram-1e5af7765d8

def sendTextTelegram(message) {
    def encodedMessage = URLEncoder.encode(message, "UTF-8")

    withCredentials(
        [string(credentialsId: 'telegram_bot_Token', variable: 'TOKEN'),
        string(credentialsId: 'telegram_Jenkins_ChatId', variable: 'CHAT_ID')]) {

            response = httpRequest (consoleLogResponseBody: true,
                    contentType: 'APPLICATION_JSON',
                    httpMode: 'GET',
                    url: "https://api.telegram.org/bot$TOKEN/sendMessage?text=$encodedMessage&chat_id=$CHAT_ID&disable_web_page_preview=true",
                    validResponseCodes: '200')
            return response
    }
}