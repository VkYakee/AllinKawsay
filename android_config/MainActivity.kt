package com.allinkawsay.app

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.view.WindowManager
import androidx.core.content.FileProvider
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : AudioServiceActivity() {
    private val CHANNEL = "com.allinkawsay/native"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enable" -> {
                        aplicarFlagSecure(true)
                        result.success(true)
                    }
                    "disable" -> {
                        aplicarFlagSecure(false)
                        result.success(true)
                    }
                    "compartirArchivo" -> {
                        try {
                            val path = call.argument<String>("path")
                            if (path == null) {
                                result.error("NO_PATH", "Falta la ruta", null)
                                return@setMethodCallHandler
                            }
                            val file = File(path)
                            val uri = FileProvider.getUriForFile(
                                this,
                                "$packageName.fileprovider",
                                file
                            )
                            val intent = Intent(Intent.ACTION_SEND).apply {
                                type = "image/png"
                                putExtra(Intent.EXTRA_STREAM, uri)
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                            }
                            startActivity(Intent.createChooser(intent, "Compartir imagen"))
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                    "guardarEnDescargas" -> {
                        try {
                            val bytes = call.argument<ByteArray>("bytes")
                            val nombre = call.argument<String>("nombre") ?: "archivo"
                            val mime = call.argument<String>("mime")
                                ?: "application/octet-stream"

                            if (bytes == null) {
                                result.error("NO_BYTES", "No hay datos", null)
                                return@setMethodCallHandler
                            }

                            val uri = guardarEnDescargas(bytes, nombre, mime)
                            if (uri != null) {
                                result.success(uri.toString())
                            } else {
                                result.error("ERROR", "No se pudo guardar", null)
                            }
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                    "instalarApk" -> {
                        try {
                            val path = call.argument<String>("path")
                            if (path == null) {
                                result.error("NO_PATH", "Falta la ruta del APK", null)
                                return@setMethodCallHandler
                            }
                            val file = File(path)
                            if (!file.exists()) {
                                result.error("NO_FILE", "El APK no existe", null)
                                return@setMethodCallHandler
                            }
                            val uri = FileProvider.getUriForFile(
                                this,
                                "$packageName.fileprovider",
                                file
                            )
                            val intent = Intent(Intent.ACTION_VIEW).apply {
                                setDataAndType(
                                    uri,
                                    "application/vnd.android.package-archive"
                                )
                                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                            }
                            startActivity(intent)
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    /// Aplica FLAG_SECURE (bloquea capturas de pantalla).
    /// En Android 13+ también desactiva la captura de recientes.
    private fun aplicarFlagSecure(enable: Boolean) {
        if (enable) {
            window.setFlags(
                WindowManager.LayoutParams.FLAG_SECURE,
                WindowManager.LayoutParams.FLAG_SECURE
            )
            // Android 13+: bloquea también la captura en la vista de recientes
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                try {
                    setRecentsScreenshotEnabled(false)
                } catch (_: Exception) {}
            }
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                try {
                    setRecentsScreenshotEnabled(true)
                } catch (_: Exception) {}
            }
        }
    }

    private fun guardarEnDescargas(
        bytes: ByteArray,
        nombre: String,
        mime: String
    ): Uri? {
        return try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                val values = ContentValues().apply {
                    put(MediaStore.MediaColumns.DISPLAY_NAME, nombre)
                    put(MediaStore.MediaColumns.MIME_TYPE, mime)
                    put(
                        MediaStore.MediaColumns.RELATIVE_PATH,
                        Environment.DIRECTORY_DOWNLOADS
                    )
                }

                val resolver = contentResolver
                val uri = resolver.insert(
                    MediaStore.Downloads.EXTERNAL_CONTENT_URI,
                    values
                ) ?: return null

                resolver.openOutputStream(uri)?.use { out ->
                    out.write(bytes)
                    out.flush()
                }
                uri
            } else {
                @Suppress("DEPRECATION")
                val dir = Environment.getExternalStoragePublicDirectory(
                    Environment.DIRECTORY_DOWNLOADS
                )
                if (!dir.exists()) dir.mkdirs()
                val file = File(dir, nombre)
                file.writeBytes(bytes)
                Uri.fromFile(file)
            }
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }
}