package twilio.flutter.twilio_conversations.methods

import com.twilio.util.ErrorInfo
import com.twilio.conversations.StatusListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import twilio.flutter.twilio_conversations.TwilioConversationsPlugin
import android.util.Log

object ChatClientMethods {
    fun updateToken(call: MethodCall, result: MethodChannel.Result) {
        val token = call.argument<String>("token")
                ?: return result.error("ERROR", "Missing 'token'", null)

        TwilioConversationsPlugin.chatClient?.updateToken(token, object : StatusListener {
            override fun onSuccess() {
                Log.d("TwilioInfo", "ChatClientMethods.updateToken => onSuccess")
                result.success(null)
            }

            override fun onError(errorInfo: ErrorInfo) {
                Log.d("TwilioInfo", "ChatClientMethods.updateToken => onError: $errorInfo")
                result.error("${errorInfo.code}", errorInfo.message, errorInfo.status)
            }
        })
    }

    fun shutdown(pluginInstance: TwilioConversationsPlugin, call: MethodCall, result: MethodChannel.Result) {
        return try {
            tearDownClient(pluginInstance)
            result.success(null)
        } catch (err: Exception) {
            result.error("ERROR", err.message, null)
        }
    }

    // Shuts down the current client (if any) and clears every plugin-level reference to it,
    // mirroring the iOS teardown so both platforms behave the same once the app starts
    // calling ChatClient#shutdown (BK-6201). See the iOS tearDownClient doc for the
    // shutdown-before-create contract expected of Dart callers.
    fun tearDownClient(pluginInstance: TwilioConversationsPlugin) {
        Log.d("TwilioInfo", "ChatClientMethods.tearDownClient => shutting down client")
        TwilioConversationsPlugin.chatClient?.removeAllListeners()
        TwilioConversationsPlugin.chatClient?.shutdown()
        TwilioConversationsPlugin.chatClient = null
        pluginInstance.chatListener = null

        pluginInstance.channelChannels.values.forEach { it.setStreamHandler(null) }
        pluginInstance.channelChannels.clear()
        pluginInstance.channelListeners.clear()
    }
}
