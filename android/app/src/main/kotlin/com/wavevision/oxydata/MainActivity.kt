package com.wavevision.oxydata

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.net.wifi.WifiManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() 
{
    private val CHANNEL = "wifi_name"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isWifiConnected" -> {
                    val ssid = call.argument<String>("ssid")
                    if (ssid != null) {
                        val isConnected = isWifiConnected(this, ssid)
                        result.success(isConnected)
                    } else {
                        result.error("INVALID_ARGUMENT", "SSID not provided.", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isWifiConnected(context: Context, ssid: String): Boolean {
        val connectivityManager =
            context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
        val network = connectivityManager.activeNetwork ?: return false
        val networkCapabilities =
            connectivityManager.getNetworkCapabilities(network) ?: return false
        if (!networkCapabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)) {
            return false
        }
        val wifiManager = context.getSystemService(Context.WIFI_SERVICE) as WifiManager
        val wifiInfo = wifiManager.connectionInfo ?: return false
        val connectedSsid = wifiInfo.ssid ?: return false
        println("conected ssssid : $connectedSsid")
        val firstFourChars = ssid.substring(0, 4)
        return connectedSsid.startsWith("\"$firstFourChars") && wifiManager.isWifiEnabled
    }
}