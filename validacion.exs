defmodule Validacion do

  @moduledoc """
  Módulo de validación de pesajes.
  """

  @dias_cosecha 1..6
  @maximo_kilos_pesaje 250

  def validar_pesaje(pesaje, recolectores, lotes) do

    with :ok <- validar_recolector(pesaje, recolectores),
      :ok <- validar_lote(pesaje, lotes),
      :ok <- validar_dia(pesaje),
      :ok <- validar_kilos(pesaje),
      :ok <- validar_verdes(pesaje) do
        {:ok, pesaje_valido}
      else
        {:error, motivo} -> {:error, motivo}
      end
    end

    #validar si existe un recolector en la lista de recolectores con el codigo del recolector que esta en el pesaje
    defp validar_recolector(%{recolector: codigo}, recolectores) when not is_nil(codigo) do

      case Enum.find(recolectores, fn recolector -> recolector.codigo == codigo end ) do
        nil -> {:error, :recolector_descocnocido}
        _recolector_encontrado -> :ok
      end
    end
    defp validar_recolector(_pesaje, _recolectores), do: {:error, :recolector_invalido}


    #validar si existe un lote en la lista de lotes con el id del lote que esta en el pesaje
    defp validar_lote(%{lote: id}, lotes) when not is_nil(id) do

      case Enum.find(lotes, fn lote -> lote.id == id end) do
        nil -> {:error, :lote_desconocido}
        _lote_encontrado -> :ok
      end
    end
    defp validar_lote(_pesaje, _lote), do: {:error, :lote_invalido}


    #Validar si el dia del pesaje esta en el rango de 1 al 6 y es entero
    defp validar_dia(%{dia: dia}) when is_integer(dia) do
      if dia in @dias_cosecha do
        :ok
      else
        {:error, :dia_invalido}
      end
    end
    defp validar_dia(_pesaje), do: {:error, :dia_invalido}


    #validar si el el numero de kilos es positivo y no pasa el maximo
    defp validar_kilos(%{kilos: kilos}) when is_number(kilos) and kilos > 0 and kilos <= @kilos_maximo_pesaje, do: :ok
    defp validar_kilos(%{kilos: kilos}) when is_number(kilos), do: ({:error, :kilos_fuera_de_rango})
    defp validar_kilos(_pesaje), do: {:error, :kilos_invalido}

    #validar si el porcentaje de verdes esta entre 0 y 100
  defp validar_verdes(%{kilos: kilos, verdes: verdes}) when is_number(verdes) and is_number(kilos) and kilos > 0 do
    porcentaje_verdes = (verdes * 100) / kilos

    if porcentaje_verdes >= 0 and porcentaje_verdes <= 100 do
      :ok
    else
      {:error, :porcentaje_invalido}
    end
  end
  defp validar_verdes(_pesaje), do: {:error, :verdes_invalido}

  #clasificar los pesajes entre validos e invalidos y retornarlo en una tupla con las dos listas
  def clasificar_pesajes(pesajes, recolectores, lotes) when is_list(pesajes) do

    {validos, invalidos} = Enum.reduce(pesajes, {[], []}, fn pesaje, {acc_validos, acc_invalidos} ->

        case validar_pesaje(pesaje, recolectores, lotes) do
          {:ok, pesaje_valido} ->
            {[pesaje_valido | acc_validos], acc_invalidos}

          {:error, motivo} ->
            {acc_validos, [{pesaje, motivo} | acc_invalidos]}
        end
      end)

    {:ok, Enum.reverse(validos), Enum.reverse(invalidos)}
  end

end
