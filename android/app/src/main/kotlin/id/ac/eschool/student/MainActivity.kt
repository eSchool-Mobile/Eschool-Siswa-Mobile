package id.ac.eschool.student

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.media.AudioManager
import android.os.Handler
import android.os.Build
import android.os.Environment
import android.content.ContentValues
import android.provider.MediaStore
import android.net.Uri
import java.io.File
import java.io.FileInputStream
import java.io.OutputStream
import android.os.Vibrator
import android.os.VibrationEffect
import android.os.Looper

// ==== IMPORT TAMBAHAN UNTUK ALARM ====
import android.app.NotificationManager
import android.app.NotificationChannel
import android.media.Ringtone
import android.media.RingtoneManager
import android.media.AudioAttributes
import androidx.core.app.NotificationCompat
// =====================================

class MainActivity : FlutterFragmentActivity() {

    private val CHANNEL = "com.eschool/security"
    private val CHANNEL_AUDIO = "com.eschool/audio"
    private val CHANNEL_MEDIASTORE = "com.eschool/mediastore"

    private var alarmHandler: Handler? = null
    private var alarmRunnable: Runnable? = null
    private var hasSubmitted = false

    // ===== ALARM (BARU) =====
    private val ALARM_CHANNEL_ID = "alarm_channel"
    private var alarmRingtone: Ringtone? = null

    private fun ensureAlarmChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            if (nm.getNotificationChannel(ALARM_CHANNEL_ID) == null) {
                val ch = NotificationChannel(
                    ALARM_CHANNEL_ID,
                    "Alarms",
                    NotificationManager.IMPORTANCE_HIGH
                ).apply {
                    description = "Alarm & pengingat"
                    enableVibration(true)
                    // Suara akan diatur via Ringtone di bawah (USAGE_ALARM)
                }
                nm.createNotificationChannel(ch)
            }
        }
    }

    private fun showAlarmNotification() {
        ensureAlarmChannel()
        val nm = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val notif = NotificationCompat.Builder(this, ALARM_CHANNEL_ID)
            .setSmallIcon(android.R.drawable.ic_lock_idle_alarm)
            .setContentTitle("Waktu habis")
            .setContentText("Alarm ujian berbunyi")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setAutoCancel(true)
            .build()
        nm.notify(1001, notif)
    }

    private fun playAlarmTone() {
        val uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_ALARM)
            ?: RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        alarmRingtone = RingtoneManager.getRingtone(this, uri)?.apply {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                audioAttributes = AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_ALARM)
                    .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                    .build()
            }
            play()
        }
    }

    private fun stopAlarmTone() {
        alarmRingtone?.stop()
        alarmRingtone = null
    }
    // ===== /ALARM (BARU) =====

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecure" -> {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    result.success(null)
                }

                "disableSecure" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_AUDIO).setMethodCallHandler { call, result ->
            when (call.method) {
                "setMaxVolume" -> {
                    try {
                        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
                        val maxVolume = audioManager.getStreamMaxVolume(AudioManager.STREAM_MUSIC) * 2
                        val lowVolume = 1
                        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, maxVolume, 0)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("VOLUME_ERROR", "Gagal mengatur volume", null)
                    }
                }
                "vibrate" -> {
                    try {
                        val vibrator = getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                            vibrator.vibrate(
                                VibrationEffect.createOneShot(
                                    1000,
                                    VibrationEffect.DEFAULT_AMPLITUDE
                                )
                            )
                        } else {
                            vibrator.vibrate(1000)
                        }
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("VIBRATE_ERROR", "Gagal melakukan getaran", null)
                    }
                }

                "startNativeTimer" -> {
                    startAlarmCountdown(result)
                }

                "cancelNativeTimer" -> {
                    cancelAlarmCountdown(result)
                }

                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL_MEDIASTORE).setMethodCallHandler { call, result ->
            if (call.method == "saveToDownloads") {
                val filePath = call.argument<String>("filePath")
                val fileName = call.argument<String>("fileName")
                val mimeType = call.argument<String>("mimeType") ?: "application/octet-stream"

                if (filePath != null && fileName != null) {
                    val success = saveFileToDownloads(applicationContext, filePath, fileName, mimeType)
                    result.success(success)
                } else {
                    result.error("INVALID", "Path or filename is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startAlarmCountdown(result: MethodChannel.Result) {
        alarmHandler?.removeCallbacks(alarmRunnable ?: Runnable { })
        hasSubmitted = false

        alarmHandler = Handler(Looper.getMainLooper())
        alarmRunnable = Runnable {
            hasSubmitted = true
 
            showAlarmNotification()
            playAlarmTone()
        
            result.success("submit")
        }
        alarmHandler?.postDelayed(alarmRunnable!!, 5000)
    }

    private fun cancelAlarmCountdown(result: MethodChannel.Result) {
        alarmHandler?.removeCallbacks(alarmRunnable ?: Runnable { })
        // === ALARM: hentikan nada alarm ===
        stopAlarmTone()
        if (hasSubmitted) {
            result.success("submit")
        } else {
            result.success("back")
        }
    }

    private fun stopSoundIfPlaying() {
        val audioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        audioManager.setStreamVolume(AudioManager.STREAM_MUSIC, 0, 0)
    }

    private fun saveFileToDownloads(context: Context, filePath: String, fileName: String, mimeType: String): Boolean {
        try {
            val resolver = context.contentResolver

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val values = ContentValues().apply {
                    put(MediaStore.Downloads.DISPLAY_NAME, fileName)
                    put(MediaStore.Downloads.MIME_TYPE, mimeType)
                    put(MediaStore.Downloads.RELATIVE_PATH, Environment.DIRECTORY_DOWNLOADS)
                }

                val uri: Uri? = resolver.insert(MediaStore.Downloads.EXTERNAL_CONTENT_URI, values)
                if (uri != null) {
                    resolver.openOutputStream(uri).use { outStream: OutputStream? ->
                        FileInputStream(File(filePath)).use { inputStream ->
                            inputStream.copyTo(outStream!!)
                        }
                    }
                    return true
                }
            } else {
                val downloadsDir = Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS)
                val destFile = File(downloadsDir, fileName)
                FileInputStream(File(filePath)).use { inputStream ->
                    destFile.outputStream().use { output ->
                        inputStream.copyTo(output)
                    }
                }
                return true
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return false
    }
}
