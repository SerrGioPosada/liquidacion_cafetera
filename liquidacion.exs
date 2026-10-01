defmodule Liquidacion do
  @moduledoc """
  Módulo encargado de calcular los pagos de los recolectores
  según la producción y las reglas de la finca.
  """

  @tarifa_base_kilo 1000
  @kilos_bonificacion 120
  @bonificacion_diaria 8000
  @descuento_alimentacion 12000

  # 1. VALOR DE UN PESAJE
  @doc """
  Calcula el valor de un pesaje según los kilos recolectados
  y el porcentaje de café verde registrado.
  Aplica un factor de ajuste según el porcentaje de granos verdes.
  """
  def valor_pesaje(pesaje) do
    kilos = pesaje.kilos
    verdes = pesaje.verdes

    porcentaje_verdes = verdes

    factor =
      cond do
        porcentaje_verdes <= 2 -> 1.05
        porcentaje_verdes <= 5 -> 1.00
        porcentaje_verdes <= 10 -> 0.90
        true -> 0.70
      end

    kilos * @tarifa_base_kilo * factor
  end

  # 2. BONIFICACIÓN POR PRODUCTIVIDAD

  @doc """
  Calcula las bonificaciones obtenidas por un recolector
  según los kilos válidos que recogió cada día.
  """
  def bonificacion(pesajes) do
    kilos_por_dia =
      Enum.reduce(pesajes, %{}, fn pesaje, acc ->
        Map.update(
          acc,
          pesaje.dia,
          pesaje.kilos,
          fn kilos -> kilos + pesaje.kilos end
        )
      end)

    Enum.reduce(kilos_por_dia, 0, fn {_dia, kilos}, total ->
      if kilos >= @kilos_bonificacion do
        total + @bonificacion_diaria
      else
        total
      end
    end)
  end

  # 3. DESCUENTO DE ALIMENTACIÓN

  @doc """
  Calcula el descuento de alimentación según los días
  en los que el recolector tuvo pesajes válidos.
  """
  def descuento_alimentacion(recolector, pesajes) do
    if Map.get(recolector, :alimentacion, false) do
      dias_trabajados =
        Enum.reduce(pesajes, %{}, fn pesaje, acc ->
          Map.put(acc, pesaje.dia, true)
        end)

      length(Map.keys(dias_trabajados)) * @descuento_alimentacion
    else
      0
    end
  end

  # 4. LIQUIDACIÓN INDIVIDUAL

  @doc """
  Calcula los valores totales de un recolector.
  """
  def liquidar_recolector(recolector, pesajes) do
    pesajes_recolector =
      Enum.filter(pesajes, fn pesaje ->
        pesaje.recolector == recolector.codigo
      end)

    kilos_totales =
      Enum.reduce(pesajes_recolector, 0, fn pesaje, total ->
        total + pesaje.kilos
      end)

    suma_pesajes =
      Enum.reduce(pesajes_recolector, 0, fn pesaje, total ->
        total + valor_pesaje(pesaje)
      end)

    bonificaciones = bonificacion(pesajes_recolector)

    alimentacion =
      descuento_alimentacion(recolector, pesajes_recolector)

    neto = suma_pesajes + bonificaciones - alimentacion

    %{
      codigo: recolector.codigo,
      nombre: recolector.nombre,
      kilos: kilos_totales,
      suma_pesajes: suma_pesajes,
      bonificaciones: bonificaciones,
      alimentacion: alimentacion,
      neto: neto
    }
  end

  # 5. LIQUIDACIÓN DE TODOS LOS RECOLECTORES

  @doc """
  Calcula la liquidación de todos los recolectores.
  Recibe los recolectores como una lista o un mapa
  y devuelve una lista con el resultado de cada liquidación.
  """
  def liquidar(recolectores, pesajes_validos) do
    recolectores_lista =
      if is_map(recolectores) do
        Map.values(recolectores)
      else
        recolectores
      end

    Enum.map(recolectores_lista, fn recolector ->
      liquidar_recolector(recolector, pesajes_validos)
    end)
  end
end
