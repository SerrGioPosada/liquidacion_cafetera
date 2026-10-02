## Integrantes del Grupo
# Sergio Posada Garcia
# Jhonatan Perilla Betancur
# Sara Benjumea Gallego

defmodule Util do
  @moduledoc """
  Modulo de utilidades e interaccion de entrada por teclado y salida en consola.
  """

  # RECOLECTORES

  @doc """
  Registra y normaliza la coleccion de recolectores a un mapa indexado por codigo.
  """
  def registrar_recolectores(recolectores) when is_list(recolectores) do
    Enum.reduce(recolectores, %{}, fn elemento, acc ->
      case normalizar_recolector(elemento) do
        %{codigo: codigo} = mapa when not is_nil(codigo) -> Map.put(acc, codigo, mapa)
        _ -> acc
      end
    end)
  end

  def registrar_recolectores(recolectores) when is_map(recolectores) do
    Map.new(recolectores, fn {clave, valor} ->
      mapa = normalizar_recolector(valor, clave)
      {mapa.codigo || clave, mapa}
    end)
  end

  def registrar_recolectores(_invalido), do: %{}

  defp normalizar_recolector(sublista) when is_list(sublista) do
    %{
      codigo: Enum.at(sublista, 0),
      nombre: Enum.at(sublista, 1),
      alimentacion: Enum.at(sublista, 2, false)
    }
  end

  defp normalizar_recolector(mapa) when is_map(mapa), do: mapa
  defp normalizar_recolector(_), do: %{}

  defp normalizar_recolector(sublista, clave_respaldo) when is_list(sublista) do
    %{
      codigo: Enum.at(sublista, 0, clave_respaldo),
      nombre: Enum.at(sublista, 1),
      alimentacion: Enum.at(sublista, 2, false)
    }
  end

  defp normalizar_recolector(mapa, _clave), do: normalizar_recolector(mapa)

  # LOTES

  @doc """
  Registra y normaliza la coleccion de lotes a un mapa indexado por ID.
  """
  def registrar_lotes(lotes) when is_list(lotes) do
    Enum.reduce(lotes, %{}, fn elemento, acc ->
      case normalizar_lote(elemento) do
        %{id: id} = mapa when not is_nil(id) -> Map.put(acc, id, mapa)
        _ -> acc
      end
    end)
  end

  def registrar_lotes(lotes) when is_map(lotes) do
    Map.new(lotes, fn {clave, valor} ->
      mapa = normalizar_lote(valor, clave)
      {mapa.id || clave, mapa}
    end)
  end

  def registrar_lotes(_invalido), do: %{}

  defp normalizar_lote(sublista) when is_list(sublista) do
    %{
      id: Enum.at(sublista, 0),
      nombre: Enum.at(sublista, 1),
      hectareas: Enum.at(sublista, 2)
    }
  end

  defp normalizar_lote(mapa) when is_map(mapa), do: mapa
  defp normalizar_lote(_), do: %{}

  defp normalizar_lote(sublista, clave_respaldo) when is_list(sublista) do
    %{
      id: Enum.at(sublista, 0, clave_respaldo),
      nombre: Enum.at(sublista, 1),
      hectareas: Enum.at(sublista, 2)
    }
  end

  defp normalizar_lote(mapa, _clave), do: normalizar_lote(mapa)

  # PESAJES

  @doc """
  Registra y normaliza la coleccion de pesajes retornando una lista de mapas.
  Mantiene el orden cronologico original.
  """
  def registrar_pesajes(pesajes) when is_list(pesajes) do
    Enum.reduce(pesajes, [], fn elemento, acc ->
      case normalizar_pesaje(elemento) do
        %{recolector: rec} = mapa when not is_nil(rec) -> [mapa | acc]
        _ -> acc
      end
    end)
    |> Enum.reverse()
  end

  def registrar_pesajes(pesajes) when is_map(pesajes) do
    Enum.reduce(pesajes, [], fn {clave, valor}, acc ->
      case normalizar_pesaje(valor, clave) do
        %{recolector: rec} = mapa when not is_nil(rec) -> [mapa | acc]
        _ -> acc
      end
    end)
    |> Enum.reverse()
  end

  def registrar_pesajes(_invalido), do: []

  defp normalizar_pesaje(sublista) when is_list(sublista) do
    %{
      recolector: Enum.at(sublista, 0),
      lote: Enum.at(sublista, 1),
      dia: Enum.at(sublista, 2),
      kilos: Enum.at(sublista, 3),
      verdes: Enum.at(sublista, 4, 0)
    }
  end

  defp normalizar_pesaje(mapa) when is_map(mapa), do: mapa
  defp normalizar_pesaje(_), do: %{}

  defp normalizar_pesaje(sublista, _clave) when is_list(sublista) do
    normalizar_pesaje(sublista)
  end

  defp normalizar_pesaje(mapa, _clave), do: normalizar_pesaje(mapa)

  # ENTRADA Y SALIDA / CONSOLA

  @doc """
  Imprime un mensaje en la consola.
  """
  def imprimir(mensaje) do
    IO.puts(mensaje)
  end

  @doc """
  Imprime una estructura de datos inspeccionada con formato legible.
  """
  def inspeccionar(dato) do
    IO.inspect(dato, pretty: true)
  end

  @doc """
  Lee una cadena de texto desde la consola eliminando saltos de linea.
  """
  def leer_string(mensaje) do
    mensaje
    |> IO.gets()
    |> to_string()
    |> String.trim()
  end

  @doc """
  Lee un entero de consola una sola vez.
  """
  def leer_entero(mensaje) do
    entrada = leer_string(mensaje)

    case Integer.parse(entrada) do
      {numero, ""} ->
        numero

      _ ->
        imprimir(" Error: Debe ingresar un numero entero valido.")
        {:error, :entrada_invalida}
    end
  end

  @doc """
  Lee un numero flotante de consola una sola vez.
  """
  def leer_float(mensaje) do
    entrada = leer_string(mensaje)

    case Float.parse(entrada) do
      {numero, ""} ->
        numero

      _ ->
        case Integer.parse(entrada) do
          {numero, ""} ->
            numero * 1.0

          _ ->
            imprimir(" Error: Debe ingresar un valor numerico valido.")
            {:error, :entrada_invalida}
        end
    end
  end

  @doc """
  Muestra los reportes en consola formateando adecuadamente cualquier tipo de retorno.
  """
  def mostrar_reportes(lista_reportes) when is_list(lista_reportes) do
    titulos = [
      "R1. PESAJES RECHAZADOS Y MOTIVOS",
      "R2. RENDIMIENTO POR LOTE",
      "R3. CUMPLIMIENTO DE META DIARIA",
      "R4. LIQUIDACION Y RANKING DE RECOLECTORES",
      "R5. MEJORES RECOLECTORES POR DIA",
      "R6. MEJOR CALIDAD (MENOR % VERDES PONDERADO)",
      "R7. TOTAL PAGADO Y COSTO PROMEDIO POR KILO",
      "R8. RECOLECTORES QUE TRABAJARON EN TODOS LOS LOTES"
    ]

    Enum.zip(titulos, lista_reportes)
    |> Enum.each(fn {titulo, reporte} ->
      mostrar_titulo(titulo)
      imprimir_reporte_formateado(reporte)
      pausar()
    end)
  end

  # Auxiliares para formatear los retornos de Reportes R1 - R8

  # R1: Tupla {invalidos, motivos_mapa}
  defp imprimir_reporte_formateado({invalidos, motivos}) when is_map(motivos) do
    IO.puts("Total de pesajes rechazados: #{length(invalidos)}")
    IO.puts("Desglose por motivo:")
    Enum.each(motivos, fn {motivo, cantidad} ->
      IO.puts("  - #{motivo}: #{cantidad}")
    end)
  end

  # R6: Tupla {codigo_string, porcentaje_numero}
  defp imprimir_reporte_formateado({codigo, porcentaje}) when is_binary(codigo) and is_number(porcentaje) do
    IO.puts("Recolector con mejor calidad: #{codigo}")
    IO.puts("Porcentaje ponderado de verde: #{Float.round(porcentaje * 1.0, 2)}%")
  end

  # R7: Tupla {total_pagado_numero, costo_promedio_numero}
  defp imprimir_reporte_formateado({total_pagado, costo_promedio}) when is_number(total_pagado) and is_number(costo_promedio) do
    IO.puts("Total pagado: $#{Float.round(total_pagado * 1.0, 2)}")
    IO.puts("Costo promedio por kilo valido: $#{Float.round(costo_promedio * 1.0, 2)}")
  end

  # R3: Tupla {reportes_dias, todos_boolean, alguno_boolean}
  defp imprimir_reporte_formateado({reportes_dias, todos, alguno}) when is_list(reportes_dias) do
    Enum.each(reportes_dias, fn {dia, kilos, cumplio} ->
      estado = if cumplio, do: "CUMPLIO META", else: "NO CUMPLIO META"
      IO.puts("Dia #{dia}: #{Float.round(kilos * 1.0, 2)} kg -> #{estado}")
    end)
    IO.puts("\nEvaluacion general:")
    IO.puts("  - ¿Cumplio todos los dias?: #{if todos, do: "SI", else: "NO"}")
    IO.puts("  - ¿Cumplio al menos un dia?: #{if alguno, do: "SI", else: "NO"}")
  end

  # R5: Tupla {mejores_por_dia_lista, mejores_totales}
  defp imprimir_reporte_formateado({mejores_por_dia, mejores_totales}) when is_list(mejores_por_dia) do
    IO.puts("--- Ganadores por dia ---")
    Enum.each(mejores_por_dia, fn
      {dia, :sin_pesajes_validos} ->
        IO.puts("Dia #{dia}: Sin pesajes validos")

      {dia, ganadores} ->
        lista_ganadores = Enum.map_join(ganadores, ", ", fn {cod, k} -> "#{cod} (#{Float.round(k * 1.0, 2)} kg)" end)
        IO.puts("Dia #{dia}: #{lista_ganadores}")
    end)

    IO.puts("\n--- Mas dias siendo el mejor ---")
    Enum.each(mejores_totales, fn {codigo, dias} ->
      IO.puts("  - Recolector #{codigo}: #{dias} dia(s)")
    end)
  end

# R2, R4, R8: Listas estructuradas
  defp imprimir_reporte_formateado(items) when is_list(items) do
    Enum.each(items, fn
      {id, nombre, kilos, rendimiento} ->
        IO.puts("Lote: [#{id}] #{nombre} | Kilos: #{redondear(kilos)} kg | Rendimiento: #{redondear(rendimiento)} kg/ha")

      # AQUI ESTA EL CAMBIO PARA R4 Y RANKING
      {liq, posicion} when is_map(liq) ->
        bruto = Map.get(liq, :suma_pesajes, Map.get(liq, :bruto, 0.0))
        bonif = Map.get(liq, :bonificaciones, 0.0)
        alim = Map.get(liq, :alimentacion, Map.get(liq, :descuento, 0.0))
        neto = Map.get(liq, :neto, 0.0)
        kilos = Map.get(liq, :kilos, 0.0)

        IO.puts(
          "#{posicion}. [#{liq.codigo}] #{liq.nombre} | " <>
          "Kilos: #{redondear(kilos)} kg | " <>
          "Bruto: #{formatear_moneda(bruto)} | " <>
          "Bonif: +#{formatear_moneda(bonif)} | " <>
          "Alim: -#{formatear_moneda(alim)} | " <>
          "Neto: #{formatear_moneda(neto)}"
        )

      %{codigo: codigo, nombre: nombre} ->
        IO.puts("  - [#{codigo}] #{nombre}")

      otro ->
        IO.inspect(otro, pretty: true)
    end)
  end

  # R8 cuando devuelve String directo
  defp imprimir_reporte_formateado(texto) when is_binary(texto) do
    IO.puts(texto)
  end

  @doc """
Genera un ranking dinmico de liquidaciones usando Keyword Lists para las opciones.
Opciones soportadas:
  - campo
  - orden
  - limite
"""
def ranking(liquidaciones, opciones \\ []) do
  campo = Keyword.get(opciones, :campo, :neto)
  orden = Keyword.get(opciones, :orden, :desc)
  limite = Keyword.get(opciones, :limite, nil)

  resultado =
    liquidaciones
    |> Enum.sort_by(fn liq -> Map.get(liq, campo, 0.0) end, orden)
    |> Enum.with_index(1)

  if is_integer(limite) and limite > 0 do
    Enum.take(resultado, limite)
  else
    resultado
  end
end

  defp imprimir_reporte_formateado(otro) do
    IO.inspect(otro, pretty: true)
  end

@doc """
  Muestra el desprendible de pago de un recolector adaptado a la estructura de Liquidacion.
  """
  def mostrar_desprendible(liq) when is_map(liq) do
    # Obtenemos los valores de forma segura con respaldo
    bruto = Map.get(liq, :suma_pesajes, Map.get(liq, :bruto, 0.0))
    descuento = Map.get(liq, :alimentacion, Map.get(liq, :descuento, 0.0))
    bonificacion = Map.get(liq, :bonificaciones, 0.0)
    neto = Map.get(liq, :neto, 0.0)
    kilos = Map.get(liq, :kilos, 0.0)
    dias = Map.get(liq, :dias, 0)

    mostrar_titulo("DESPRENDIBLE DE PAGO")
    imprimir("Codigo: #{liq.codigo}")
    imprimir("Nombre: #{liq.nombre}")
    imprimir("Dias laborados: #{dias}")
    imprimir("Kilos validos: #{redondear(kilos)} kg")
    mostrar_divisor()
    imprimir("Pago Bruto (Pesajes): #{formatear_moneda(bruto)}")
    imprimir("Bonificaciones: +#{formatear_moneda(bonificacion)}")
    imprimir("Descuento Alimentacion: -#{formatear_moneda(descuento)}")
    mostrar_divisor()
    imprimir("TOTAL NETO: #{formatear_moneda(neto)}")
    mostrar_divisor()
  end

  @doc """

  Solicita y captura los datos de un pesaje adicional desde la consola.
  Muestra el formato de solicitud exactamente como pide el Anexo.
  """
  def capturar_pesaje_manual do
    entrada = leer_string("Ingrese un pesaje adicional (recolector;lote;dia;kilos;verdes) o Enter para omitir: ")

    if entrada == "" do
      {:ok, nil}
    else
      parsear_linea_pesaje(entrada)
    end
  end

  defp parsear_linea_pesaje(cadena) do
    partes = String.split(cadena, ";") |> Enum.map(&String.trim/1)

    case partes do
      [rec, lote, dia_str, kilos_str, verdes_str] ->
        with {dia, ""} <- Integer.parse(dia_str),
             {kilos, ""} <- parse_float_or_int(kilos_str),
             {verdes, ""} <- parse_float_or_int(verdes_str) do
          {:ok, %{recolector: rec, lote: lote, dia: dia, kilos: kilos * 1.0, verdes: verdes * 1.0}}
        else
          _ -> {:error, :formato_invalido}
        end

      _ ->
        {:error, :formato_invalido}
    end
  end

  defp parse_float_or_int(string) do
    case Float.parse(string) do
      {float_val, ""} -> {float_val, ""}
      _ ->
        case Integer.parse(string) do
          {int_val, ""} -> {int_val * 1.0, ""}
          _ -> :error
        end
    end
  end

  @doc """
  Imprime un titulo formateado en consola.
  """
  def mostrar_titulo(titulo) do
    linea = String.duplicate("=", String.length(titulo) + 6)
    imprimir("\n" <> linea)
    imprimir("   #{titulo}")
    imprimir(linea)
  end

  @doc """
  Imprime una linea divisoria horizontal.
  """
  def mostrar_divisor do
    imprimir(String.duplicate("-", 50))
  end

  @doc """
  Pausa la ejecucion del programa hasta presionar Enter.
  """
  def pausar do
    IO.gets("\nPresione ENTER para continuar...")
    :ok
  end

  @doc """
  Redondea un numero a 2 decimales de forma segura.
  """
  def redondear(numero) when is_number(numero) do
    Float.round(numero * 1.0, 2)
  end

  def redondear(_), do: 0.0

  @doc """
  Convierte un valor numerico a un string en formato moneda ($XX,XXX.00).
  """
  def formatear_moneda(valor) when is_number(valor) do
    "$" <> :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end

  def formatear_moneda(_), do: "$0.00"
end
