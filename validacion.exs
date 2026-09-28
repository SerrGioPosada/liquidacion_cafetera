defmodule Validacion do
  @moduledoc """
  Módulo encargado de la verificación de reglas de negocio para los pesajes de café.

  Asegura que cada registro de pesaje cumpla con la existencia del recolector y lote
  (mediante búsquedas en tiempo constante O(1)), rangos de fechas (días 1 al 6),
  kilos válidos y porcentaje de café verde dentro de los límites.
  """

  @dias_cosecha 1..6
  @maximo_kilos_pesaje 250.0

  @doc """
  Valida un único pesaje evaluando secuencialmente sus atributos.

  ## Parámetros
    - pesaje: Mapa del pesaje a validar (%{recolector: ..., lote: ..., dia: ..., kilos: ..., verdes: ...}).
    - recolectores: Mapa indexado por código de recolector (Util.registrar_recolectores/1).
    - lotes: Mapa indexado por id de lote (Util.registrar_lotes/1).

  ## Retorno
    - {:ok, pesaje} si pasa todas las reglas.
    - {:error, motivo} si falla en alguna regla.
  """
  def validar_pesaje(pesaje, recolectores, lotes) do
    with :ok <- validar_recolector(pesaje, recolectores),
         :ok <- validar_lote(pesaje, lotes),
         :ok <- validar_dia(pesaje),
         :ok <- validar_kilos(pesaje),
         :ok <- validar_verdes(pesaje) do
      {:ok, pesaje}
    else
      {:error, motivo} -> {:error, motivo}
    end
  end

  @doc """
  Clasifica una colección de pesajes en dos listas: válidos e inválidos.

  ## Parámetros
    - pesajes: Lista de mapas de pesajes normalizados (Util.registrar_pesajes/1).
    - recolectores: Mapa de recolectores procesado por Util.
    - lotes: Mapa de lotes procesado por Util.

  ## Retorno
    - {:ok, validos, invalidos} donde validos es una lista de pesajes y invalidos es una lista de tuplas {%{pesaje}, :motivo}.
  """
  def clasificar_pesajes(pesajes, recolectores, lotes) when is_list(pesajes) do
    {validos, invalidos} =
      Enum.reduce(pesajes, {[], []}, fn pesaje, {acc_validos, acc_invalidos} ->
        case validar_pesaje(pesaje, recolectores, lotes) do
          {:ok, pesaje_valido} ->
            {[pesaje_valido | acc_validos], acc_invalidos}

          {:error, motivo} ->
            {acc_validos, [{pesaje, motivo} | acc_invalidos]}
        end
      end)

    {:ok, Enum.reverse(validos), Enum.reverse(invalidos)}
  end

  def clasificar_pesajes(_invalido, _recolectores, _lotes), do: {:ok, [], []}



  # Valida si el código del recolector existe como clave en el mapa de recolectores
  defp validar_recolector(%{recolector: codigo}, recolectores) when is_map(recolectores) and not is_nil(codigo) do
    if Map.has_key?(recolectores, codigo) do
      :ok
    else
      {:error, :recolector_desconocido}
    end
  end

  defp validar_recolector(_pesaje, _recolectores), do: {:error, :recolector_invalido}

  # Valida si el id del lote existe como clave en el mapa de lotes (
  defp validar_lote(%{lote: id}, lotes) when is_map(lotes) and not is_nil(id) do
    if Map.has_key?(lotes, id) do
      :ok
    else
      {:error, :lote_desconocido}
    end
  end

  defp validar_lote(_pesaje, _lotes), do: {:error, :lote_invalido}

  # Valida si el día está dentro del rango permitido (1..6)
  defp validar_dia(%{dia: dia}) when is_integer(dia) do
    if dia in @dias_cosecha do
      :ok
    else
      {:error, :dia_invalido}
    end
  end

  defp validar_dia(_pesaje), do: {:error, :dia_invalido}

  # Valida si el valor de kilos es numérico, positivo y <= @maximo_kilos_pesaje
  defp validar_kilos(%{kilos: kilos}) when is_number(kilos) and kilos > 0 and kilos <= @maximo_kilos_pesaje do
    :ok
  end

  defp validar_kilos(%{kilos: kilos}) when is_number(kilos), do: {:error, :kilos_fuera_de_rango}
  defp validar_kilos(_pesaje), do: {:error, :kilos_invalido}

  # Valida los kilos de verde con el total cosechado
  defp validar_verdes(%{kilos: kilos, verdes: verdes}) when is_number(verdes) and is_number(kilos) and kilos > 0 do
    porcentaje_verdes = (verdes * 100) / kilos

    if porcentaje_verdes >= 0 and porcentaje_verdes <= 100 and verdes <= kilos do
      :ok
    else
      {:error, :porcentaje_invalido}
    end
  end

  defp validar_verdes(_pesaje), do: {:error, :verdes_invalido}
end
