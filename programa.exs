## Integrantes del Grupo
# Sergio Posada Garcia
# Jhonatan Perilla Betancur
# Sara Benjumea Gallego

defmodule Programa do
  @meta_diaria 300.0

  def main do
    Util.mostrar_titulo("SISTEMA DE LIQUIDACION DE COSECHA DE CAFE")

    #Cargar datos
    recolectores_lista = Datos.recolectores()
    lotes_lista = Datos.lotes()

    recolectores_mapa = Util.registrar_recolectores(recolectores_lista)
    lotes_mapa = Util.registrar_lotes(lotes_lista)
    pesajes_lista = Util.registrar_pesajes(Datos.pesajes())

    #Validar
    {:ok, validos, invalidos} = Validacion.clasificar_pesajes(pesajes_lista, recolectores_mapa, lotes_mapa)

    # Pesaje manual
    {validos, invalidos} = procesar_pesaje_manual(validos, invalidos, recolectores_mapa, lotes_mapa)

    # Generar y mostrar reportes R1 - R8
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

    # Solicitar desprendible
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
            Util.imprimir("Pesaje agregado con exito.\n")
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
    codigo_raw = Util.leer_string("Ingrese el codigo del recolector para ver su desprendible (o Enter para omitir): ")

    if codigo_raw == "" do
      Util.imprimir("No se ingreso ningún código. Finalizando programa.")
    else
      codigo = String.upcase(codigo_raw)

      case Map.get(recolectores_mapa, codigo) || Map.get(recolectores_mapa, codigo_raw) do
        nil ->
          Util.imprimir("No existe un recolector con el codigo #{codigo_raw}.")

        recolector ->
          desprendible_texto = Liquidacion.generar_desprendible(recolector, validos)
          Util.imprimir("\n" <> to_string(desprendible_texto))
      end
    end
  end
end

Programa.main()
