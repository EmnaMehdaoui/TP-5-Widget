package com.example.tp5_widget

import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager

object SourceMesure {

    // Lit la température de la batterie en degrés Celsius
    fun temperatureBatterie(context: Context): Double? {
        val etat = context.applicationContext
            .registerReceiver(
                null,
                IntentFilter(Intent.ACTION_BATTERY_CHANGED)
            ) ?: return null

        val dixiemes = etat.getIntExtra(
            BatteryManager.EXTRA_TEMPERATURE,
            Int.MIN_VALUE
        )

        return if (dixiemes == Int.MIN_VALUE) {
            null
        } else {
            dixiemes / 10.0
        }
    }

    // Lit la mesure et met à jour les widgets
    suspend fun lireEtPublier(context: Context) {
        val temperature = temperatureBatterie(context) ?: return

        WidgetMaj.enregistrer(
            context,
            temperature,
            titre = "Batterie (démo)",
            unite = "°C"
        )
    }
}
