## Integrantes del Grupo
# Sergio Posada Garcia
# Jhonatan Perilla Betancur
# Sara Benjumea Gallego

defmodule Reportes do
  @moduledoc """
  Módulo de generación de reportes

  incluyendo los pesajes validos, invalidos y los lotes y recolectores

  """

  @doc """
  genera los reportes de pesajes invalidos y muestra la cantidad
  de veces que se muetra cada invalidacion
  """
  def ranking(liquidaciones, opciones) do
    campo = Keyword.get(opciones, :campo, :neto)
    orden = Keyword.get(opciones, :orden, :desc)
    limite = Keyword.get(opciones, :limite, :todos)

    liquidaciones
    |> Enum.sort_by(fn liquidacion -> Map.get(liquidacion, campo) end, orden)
    |> aplicar_limite(limite)
    |> Enum.with_index(1)
  end

  defp aplicar_limite(liquidaciones, :todos), do: liquidaciones
  defp aplicar_limite(liquidaciones, limite), do: Enum.take(liquidaciones, limite)

  def reporte_r1(invalidos) do
    motivos =
      invalidos
      |> Enum.map(fn {_pesaje, motivo} -> motivo end)
      |> Enum.frequencies()

    {invalidos, motivos}
  end

  @doc """
  agrupa todos los pesajes valido por cada lote, segun las hectareas del lote,
  calcula los kilos recolecados y el rendimiento
  """

  def reporte_r2(validos, lotes) do
    # pesajes agrupados por lote en un mapa

    pesajes_por_lote = Enum.group_by(validos, fn pesaje -> pesaje.lote end)

    lotes
    |> Map.values()
    |> Enum.map(fn lote -> procesar_lote(lote, pesajes_por_lote) end)
    |> Enum.sort_by(fn {_id, _nombre, _kilos, rendimiento} -> rendimiento end, :desc)
  end

  defp procesar_lote(%{id: id, nombre: nombre, hectareas: hectareas}, pesajes_por_lote) do
    pesajes = Map.get(pesajes_por_lote, id, [])

    kilos = Enum.reduce(pesajes, 0, fn pesaje, acumulador -> acumulador + pesaje.kilos end)

    rendimiento = calcular_rendimiento(kilos, hectareas)

    {id, nombre, kilos, rendimiento}
  end

  defp calcular_rendimiento(_kilos, hectareas) when hectareas == 0 do
    0.0
  end

  defp calcular_rendimiento(kilos, hectareas) do
    kilos / hectareas
  end

  @doc """
  en el rango de los seis dias, se muestra si se cumplio la meta diaria junto
  con la indicacion sobre si se cumplio o no almenos un dia
  """

  def reporte_r3(validos, meta_diaria) do
    # 1. se agrupan los mensajes por dia
    pesajes_por_dia = Enum.group_by(validos, fn pesaje -> pesaje.dia end)

    # 2. se genera el reporte en el rango
    reportes =
      Enum.map(1..6, fn dia ->
        procesar_dia(dia, pesajes_por_dia, meta_diaria)
      end)

    # 3. se evaluan condiciones
    todos_cumplieron = Enum.all?(reportes, fn {_, _, cumplio} -> cumplio end)
    alguno_cumplio = Enum.any?(reportes, fn {_, _, cumplio} -> cumplio end)

    {reportes, todos_cumplieron, alguno_cumplio}
  end

  # se evalua la informacion de un dia
  defp procesar_dia(dia, pesajes_por_dia, meta_diaria) do
    pesajes_dia = Map.get(pesajes_por_dia, dia, [])
    kilos = Enum.reduce(pesajes_dia, 0.0, fn pesaje, acumulador -> acumulador + pesaje.kilos end)
    cumplio = kilos >= meta_diaria

    {dia, kilos, cumplio}
  end

  @doc """
  se genera la liquidacion de todos los recolectores, se ordena dependiendo del valor recibido
  """

  def reporte_r4(recolectores, validos) do
    pesajes_por_recolector = Enum.group_by(validos, fn pesaje -> pesaje.recolector end)

    recolectores
    |> Map.values()
    |> Enum.map(fn recolector ->
      pesajes = Map.get(pesajes_por_recolector, recolector.codigo, [])

      Liquidacion.liquidar_recolector(recolector, pesajes)
    end)
    |> Enum.sort_by(fn liquidacion -> liquidacion.neto end, :desc)
    |> Enum.with_index(1)
  end

  def formato_dinero(valor) do
    "$" <> :erlang.float_to_binary(valor, decimals: 2)
  end

  @doc """
   se muestra el reporte del mejor recolector de cada dia

   tambien se muestra si el recolector fue el mejor durante mas dias
  """

  def reporte_r5(validos, recolectores) do
    mejores_por_dia =
      Enum.map(1..6, fn dia -> mejor_del_dia(dia, validos, recolectores) end)

    ganadores =
      Enum.reduce(mejores_por_dia, [], fn resultado, acumulador ->
        agregar_ganadores(resultado, acumulador)
      end)

    veces_mejor = Enum.frequencies(ganadores)

    max_dias = Enum.max(Map.values(veces_mejor))

    mejores_totales = Enum.filter(veces_mejor, fn {_codigo, dias} -> dias == max_dias end)

    {mejores_por_dia, mejores_totales}
  end

  # si no habian pesajes valido en el dia, no se agregara ningun ganador

  defp agregar_ganadores({_dia, :sin_pesajes_validos}, acumulador) do
    acumulador
  end

  # se agregan todos los ganadores que empataron entre si

  defp agregar_ganadores({_dia, mejores}, acumulador) do
    nuevos_ganadores = Enum.map(mejores, fn {codigo, _kilos} -> codigo end)

    acumulador ++ nuevos_ganadores
  end

  defp mejor_del_dia(dia, validos, recolectores) do
    # se calculan los kilos de cada recolector
    kilos_recolectores = kilos_por_recolector(dia, validos, recolectores)

    kilos = Enum.map(kilos_recolectores, fn {_codigo, kilos} -> kilos end)

    if Enum.all?(kilos, fn kilos -> kilos == 0.0 end) do
      {dia, :sin_pesajes_validos}
    else
      maximo = Enum.max(kilos)

      mejores = Enum.filter(kilos_recolectores, fn {_codigo, kilos} -> kilos == maximo end)

      {dia, mejores}
    end
  end

  defp kilos_por_recolector(dia, validos, recolectores) do
    pesajes_por_recolector =
      validos
      |> Enum.filter(fn pesaje -> pesaje.dia == dia end)
      |> Enum.group_by(fn pesaje -> pesaje.recolector end)

    Enum.map(recolectores, fn recolector ->
      pesajes = Map.get(pesajes_por_recolector, recolector.codigo, [])

      kilos =
        Enum.reduce(pesajes, 0.0, fn pesaje, acc ->
          acc + pesaje.kilos
        end)

      {recolector.codigo, kilos}
    end)
  end

  @doc """
  determina el recolector con mejor calidad entre los que tienen
  almenos tres pesajes validos

  la calidad se determina por el porcentaje de cafe verde ponderado por los kilos recolectados
  """

  def reporte_r6(validos) do
    pesajes_por_recolector =
      Enum.group_by(validos, fn pesaje ->
        pesaje.recolector
      end)

    recolectores_validos =
      Enum.filter(pesajes_por_recolector, fn {_codigo, pesajes} ->
        length(pesajes) >= 3
      end)

    calidades =
      Enum.map(recolectores_validos, fn recolector ->
        calidad_recolector(recolector)
      end)

    mejor =
      Enum.min_by(calidades, fn {_codigo, porcentaje} ->
        porcentaje
      end)

    mejor
  end

  defp calidad_recolector({codigo, pesajes}) do
    verdes_ponderados =
      Enum.reduce(pesajes, 0.0, fn pesaje, acumulador ->
        acumulador + pesaje.verdes * pesaje.kilos
      end)

    kilos = Enum.reduce(pesajes, 0.0, fn pesaje, acumulador -> acumulador + pesaje.kilos end)

    porcentaje = verdes_ponderados / kilos

    {codigo, porcentaje}
  end

  @doc """
   se calcula el total pagado a los recolectores y el costo promedio pagado por cada kilo valido

  """

  def reporte_r7(recolectores, validos) do
    pesajes_por_recolector = Enum.group_by(validos, fn pesaje -> pesaje.recolector end)

    liquidaciones =
      recolectores
      |> Map.values()
      |> Enum.map(fn recolector ->
        pesajes = Map.get(pesajes_por_recolector, recolector.codigo, [])

        Liquidacion.liquidar_recolector(recolector, pesajes)
      end)

    total_pagado =
      Enum.reduce(liquidaciones, 0.0, fn liquidacion, acumulador ->
        acumulador + liquidacion.neto
      end)

    kilos_validos =
      Enum.reduce(liquidaciones, 0.0, fn liquidacion, acumulador ->
        acumulador + liquidacion.kilos
      end)

    costo_promedio =
      if kilos_validos == 0 do
        0.0
      else
        total_pagado / kilos_validos
      end

    {total_pagado, costo_promedio}
  end

  @doc """
  señala los recolectores que trabajaron en cada lote

   si ningun recolector cumple con la condicion, muestra un mensaje diciendo que no existe ninguno
  """

  def reporte_r8(recolectores, validos, lotes) do
    pesajes_por_recolector =
      Enum.group_by(validos, fn pesaje ->
        pesaje.recolector
      end)

    recolectores_todos_lotes =
      recolectores
      |> Map.values()
      |> Enum.filter(fn recolector ->
        pesajes = Map.get(pesajes_por_recolector, recolector.codigo, [])

        lotes
        |> Map.values()
        |> Enum.all?(fn lote ->
          Enum.any?(pesajes, fn pesaje ->
            pesaje.lote == lote.id
          end)
        end)
      end)

    if recolectores_todos_lotes == [] do
      "Ningún recolector trabajó en todos los lotes"
    else
      recolectores_todos_lotes
    end
  end
end
