defmodule Programa do
  @moduledoc """
  Orquestador principal del Sistema de Liquidador de Cosecha de Café.
  Coordina la carga de datos, validaciones, registro manual y reporte final.
  """

  @meta_diaria 300.0

  def main do
    Util.mostrar_titulo("SISTEMA DE LIQUIDACIÓN DE COSECHA DE CAFÉ")

    # Cargar y normalizar datos
    recolectores_lista = Datos.recolectores()
    lotes_lista = Datos.lotes()

    recolectores_mapa = Util.registrar_recolectores(recolectores_lista)
    lotes_mapa = Util.registrar_lotes(lotes_lista)
    pesajes_lista = Util.registrar_pesajes(Datos.pesajes())

    # Validar pesajes
    {:ok, validos, invalidos} = Validacion.clasificar_pesajes(pesajes_lista, recolectores_mapa, lotes_mapa)

    # Registrar pesaje manual opcional
    {validos, invalidos} = procesar_pesaje_manual(validos, invalidos, recolectores_mapa, lotes_mapa)

    # Generar y mostrar reportes
    [
      Reportes.reporte_r1(invalidos),
      Reportes.reporte_r2(validos, lotes_mapa),
      Reportes.reporte_r3(validos, @meta_diaria),
      Reportes.reporte_r4(recolectores_mapa, validos),
      Reportes.reporte_r5(validos, recolectores_lista),
      Reportes.reporte_r6(validos),
      Reportes.reporte_r7(recolectores_mapa, validos),
      Reportes.reporte_r8(recolectores_mapa, validos, lotes_mapa)
    ]
    |> Util.mostrar_reportes()
  end

  defp procesar_pesaje_manual(validos, invalidos, recolectores_mapa, lotes_mapa) do
    case Util.capturar_pesaje_manual() do
      {:ok, nil} ->
        {validos, invalidos}

      {:ok, pesaje} ->
        case Validacion.validar_pesaje(pesaje, recolectores_mapa, lotes_mapa) do
          {:ok, pesaje_valido} -> {[pesaje_valido | validos], invalidos}
          {:error, motivo} -> {validos, [{pesaje, motivo} | invalidos]}
        end

      {:error, motivo} ->
        {validos, [{%{raw: "Entrada manual"}, motivo} | invalidos]}
    end
  end
end

Programa.main()
