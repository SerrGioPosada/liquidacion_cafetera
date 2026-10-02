## Integrantes del Grupo
# Sergio Posada Garcia
# Jhonatan Perilla Betancur
# Sara Benjumea Gallego

defmodule Programa do
  @moduledoc """
  Modulo principal del programa de liquidacion de cosecha de cafe.
  """

  @meta_diaria 400.0

  @doc """
  Punto de entrada principal de la aplicacion.
  """
  def main do
    Util.mostrar_titulo("SISTEMA DE LIQUIDACION DE COSECHA DE CAFE")

    # Cargar datos
    recolectores_lista = Datos.recolectores()
    lotes_lista = Datos.lotes()

    recolectores_mapa = Util.registrar_recolectores(recolectores_lista)
    lotes_mapa = Util.registrar_lotes(lotes_lista)
    pesajes_lista = Util.registrar_pesajes(Datos.pesajes())

    # Validar pesajes
    {:ok, validos, invalidos} = Validacion.clasificar_pesajes(pesajes_lista, recolectores_mapa, lotes_mapa)

    # Capturar pesaje manual opcional
    {validos, invalidos} = procesar_pesaje_manual(validos, invalidos, recolectores_mapa, lotes_mapa)

    # Generar y mostrar reportes estándar R1 - R8
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

    # Demostrar rankings parametrizados usando Liquidacion.liquidar
    liquidaciones = Liquidacion.liquidar(recolectores_mapa, validos)

    Util.mostrar_titulo("RANKINGS")

    Util.imprimir("\n--- 1. Ranking por defecto: ---")
    Reportes.ranking(liquidaciones, []) |> Util.imprimir_reporte_formateado()
    Util.pausar()

    Util.imprimir("\n--- 2. Ranking Top 3 por Kilos: ---")
    Reportes.ranking(liquidaciones, campo: :kilos, limite: 3) |> Util.imprimir_reporte_formateado()
    Util.pausar()

    Util.imprimir("\n--- 3. Ranking por Bruto Ascendente: ---")
    Reportes.ranking(liquidaciones, orden: :asc, campo: :suma_pesajes) |> Util.imprimir_reporte_formateado()
    Util.pausar()

    # Solicitar e imprimir desprendible individual
    solicitar_desprendible(recolectores_mapa, validos)
  end

  defp procesar_pesaje_manual(validos, invalidos, recolectores_mapa, lotes_mapa) do
    case Util.capturar_pesaje_manual() do
      {:ok, nil} ->
        Util.imprimir("No se agrego ningun pesaje.\n")
        {validos, invalidos}

      {:ok, pesaje} ->
        case Validacion.validar_pesaje(pesaje, recolectores_mapa, lotes_mapa) do
          {:ok, pesaje_valido} ->
            p = pesaje_valido
            Util.imprimir("Pesaje agregado: #{p.recolector} en #{p.lote}, día #{p.dia}, #{p.kilos} kg, #{p.verdes}% de verdes.\n")
            {[pesaje_valido | validos], invalidos}

          {:error, motivo} ->
            Util.imprimir("Pesaje rechazado: #{motivo}\n")
            {validos, [{pesaje, motivo} | invalidos]}
        end

      {:error, motivo} ->
        Util.imprimir("Pesaje rechazado: #{motivo}\n")
        {validos, [{%{raw: "Entrada manual"}, motivo} | invalidos]}
    end
  end

  defp solicitar_desprendible(recolectores_mapa, validos) do
    codigo_raw = Util.leer_string("Ingrese el código del recolector para ver su desprendible (o Enter para omitir): ")

    if codigo_raw == "" do
      Util.imprimir("No se selecciono ningun recolector. Finalizando programa.")
    else
      codigo = String.upcase(codigo_raw)

      case Map.get(recolectores_mapa, codigo) || Map.get(recolectores_mapa, codigo_raw) do
        nil ->
          Util.imprimir("No existe un recolector con el código #{codigo_raw}.")

        recolector ->
          Util.mostrar_desprendible(Liquidacion.liquidar_recolector(recolector, validos))
      end
    end
  end
end

Programa.main()
