defmodule Util do
  @moduledoc """
  Módulo de utilidades e interacción de entrada por teclado.
  """

  # RECOLECTORES

  @doc """
  Registra y normaliza la colección de recolectores a un mapa indexado por código.
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

  # Funciones privadas para transformar UN SOLO recolector
  defp normalizar_recolector(sublista) when is_list(sublista) do
    %{
      codigo: Enum.at(sublista, 0),
      nombre: Enum.at(sublista, 1),
      recibe_alimentacion: Enum.at(sublista, 2, false)
    }
  end

  defp normalizar_recolector(mapa) when is_map(mapa), do: mapa
  defp normalizar_recolector(_), do: %{}

  defp normalizar_recolector(sublista, clave_respaldo) when is_list(sublista) do
    %{
      codigo: Enum.at(sublista, 0, clave_respaldo),
      nombre: Enum.at(sublista, 1),
      recibe_alimentacion: Enum.at(sublista, 2, false)
    }
  end

  defp normalizar_recolector(mapa, _clave), do: normalizar_recolector(mapa)

  # LOTES

  @doc """
  Registra y normaliza la colección de lotes a un mapa indexado por ID.
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

  # Funciones privadas para transformar UN SOLO lote
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
  Registra y normaliza la colección de pesajes retornando siempre una lista de mapas.
  Mantiene el orden cronológico original.
  """
  # Si los pesajes vienen en una Lista (Lista de Listas o Lista de Mapas)
  def registrar_pesajes(pesajes) when is_list(pesajes) do
    Enum.reduce(pesajes, [], fn elemento, acc ->
      case normalizar_pesaje(elemento) do
        %{recolector: rec} = mapa when not is_nil(rec) -> [mapa | acc]
        _ -> acc
      end
    end)
    |> Enum.reverse()
  end

  # Si los pesajes vienen en un Mapa (Mapa de Listas o Mapa de Mapas)
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

  # Funciones privadas para transformar UN SOLO pesaje a Mapa

  # Cuando el pesaje individual es una LISTA [recolector, lote, dia, kilos, verdes]
  defp normalizar_pesaje(sublista) when is_list(sublista) do
    %{
      recolector: Enum.at(sublista, 0),
      lote: Enum.at(sublista, 1),
      dia: Enum.at(sublista, 2),
      kilos: Enum.at(sublista, 3),
      verdes: Enum.at(sublista, 4, 0)
    }
  end

  # Cuando el pesaje individual ya es un MAPA
  defp normalizar_pesaje(mapa) when is_map(mapa), do: mapa

  defp normalizar_pesaje(_), do: %{}

  # Cuando el pesaje viene en un Mapa exterior (%{"P01" => [...]})
  defp normalizar_pesaje(sublista, _clave) when is_list(sublista) do
    normalizar_pesaje(sublista)
  end

  defp normalizar_pesaje(mapa, _clave), do: normalizar_pesaje(mapa)

  @doc """
  Lee una cadena de texto desde la consola eliminando saltos de línea.
  """
  def leer_string(mensaje) do
    mensaje
    |> IO.gets()
    |> to_string()
    |> String.trim()
  end

  @doc """
  Lee un entero de consola. Reintenta en caso de entrada inválida.
  """
  def leer_entero(mensaje) do
    entrada = leer_string(mensaje)

    case Integer.parse(entrada) do
      {numero, ""} ->
        numero

      _ ->
        IO.puts(" Error: Debe ingresar un número entero válido.")
        leer_entero(mensaje)
    end
  end

  @doc """
  Lee un número flotante de consola (o convierte entero a float). Reintenta si falla.
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
            IO.puts(" Error: Debe ingresar un valor numérico válido.")
            leer_float(mensaje)
        end
    end
  end
 

  @doc """
  Imprime un título formateado en consola.
  """
  def mostrar_titulo(titulo) do
    linea = String.duplicate("=", String.length(titulo) + 6)
    IO.puts("\n" <> linea)
    IO.puts("   #{titulo}")
    IO.puts(linea)
  end

  @doc """
  Imprime una línea divisoria horizontal.
  """
  def mostrar_divisor do
    IO.puts(String.duplicate("-", 50))
  end

  @doc """
  Pausa la ejecución del programa hasta presionar Enter.
  """
  def pausar do
    IO.gets("\nPresione ENTER para continuar...")
    :ok
  end



  @doc """
  Redondea un número a 2 decimales de forma segura.
  """
  def redondear(numero) when is_number(numero) do
    Float.round(numero * 1.0, 2)
  end

  def redondear(_), do: 0.0

  @doc """
  Convierte un valor numérico a un string en formato moneda ($XX,XXX.00).
  """
  def formatear_moneda(valor) when is_number(valor) do
    "$" <> :erlang.float_to_binary(valor * 1.0, decimals: 2)
  end

  def formatear_moneda(_), do: "$0.00"

end
