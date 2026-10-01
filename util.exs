defmodule Util do
  @moduledoc """
  Módulo de utilidades e interacción de entrada por teclado.
  """

  # RECOLECTORES

  @doc """
  Registra y normaliza la colección de recolectores a un mapa indexado por código.
  """
  #la funcion registrar recolectores recibe la lista de recolectores y usamos when is_list funcion guarda de elixir que devuelve un
  #booleano dependiendo si la coleccion es una lista o no (solo se ejecuta si llega una lista)
  def registrar_recolectores(recolectores) when is_list(recolectores) do
    #utilizamos la funcion Enum la funcion reduce/3 que tiene (argmento/coleccion, acumulador/en que lo voy a guardar en este caso lo
    #queremos guardar en un mapa,  funcion lambda que tiene fn que es el elemento en este caso cada recolector, y acc que es el acumulador que
    #en el que se vametiendo cada elemento)
    Enum.reduce(recolectores, %{}, fn elemento, acc ->
      #utilizamos la funccion normalizar_recolector/1 al que le mandamos cada sublista de recolector, esta funcion devuelve un recolector
      #en un mapa sin importar en que coleccion venga, y si ya es un mapa lo devuelve normal
      case normalizar_recolector(elemento) do
        #en caso de que el elemento sea un mapa y tenga un codigo, declaramos el resultado de normalizar_recolector(elemento) con la variable mapa,
        #con el when not is nil es un guarda que verifica que el codigo que llego no sea nulo
        #despues de verificar utiliza Map.put (mapa acumulador, clave, valor) lo que crea un nuevo mapa con el mapa de clave codigo
        %{codigo: codigo} = mapa when not is_nil(codigo) -> Map.put(acc, codigo, mapa)
        #en caso de que normalizar_recolector retorne cualquier otra cosa devuelve el mapa del acumulador como estaba
        _ -> acc
      end
    end)
  end

  #Revisa con la guarda when si la coleccion de recolectores es un mapa
  def registrar_recolectores(recolectores) when is_map(recolectores) do
    #utiliza Map.new/2 la cual es una funcion que le pasas un mapa y esa te devuelve un nuevo mapa, con un nuevo
    #clave valor para cada elemento, la lista es recolectores
    #la funcion que ejecuta para definir cada clave y valor nuevo es la siguiente, crea un nuevo mapa mapa donde le carga cada elemento,
    #y declara que es normalizar_recolector/2 la cual recibe el valor que es la lista de cada recolector y la clave
    Map.new(recolectores, fn {clave, valor} ->
      #crea un nuevo mapa mapa donde le carga cada elemento,
      #y declara que es normalizar_recolector/2 la cual recibe el valor que es la lista de cada recolector y la clave
      #de ese elemento en el mapa recolectores por si en la lista no viene el codigo.
      mapa = normalizar_recolector(valor, clave)
      # cada elemento normalizado se mete en una tupla que pide map.new la cual tiene el codigo del mapa
      # o si es nulo pasa la clave que tenia en el anterior mapa, y pasa el mapa normalizado.
      {mapa.codigo || clave, mapa}
    end)
  end

  #si recolectores es nulo o no es una coleccion devuelve un mapa vacio
  def registrar_recolectores(_invalido), do: %{}

  # Funciones privadas para transformar UN SOLO recolector
  #normalizar_recolectores/1 sublista, se ejecuta solo si el elemento es una lista, retorna un nuevo mapa
  #se ejecuta solo cuando la coleccion de recolectores es una lista
  defp normalizar_recolector(sublista) when is_list(sublista) do
    %{
      #:codigo es igual al dato del indice 0 de la sublita del recolector
      codigo: Enum.at(sublista, 0),
      #:nombre es igual al dato del indice 1 de la sublita del recolector
      nombre: Enum.at(sublista, 1),
      #:alimentacion es igual al dato del indice 2 de la sublita del recolector, como es un booleano si viene vacio por defecto es false
      alimentacion: Enum.at(sublista, 2, false)
    }
  end

  #si el elemento que recibe es una coleccion mapa devuelve el mapa tal como le llego
  defp normalizar_recolector(mapa) when is_map(mapa), do: mapa
  #si llego vacio o no es un mapa ni una lista devuelve un mapa vacio
  defp normalizar_recolector(_), do: %{}


  #normalizar_recolector/2 recibe un valor/sublista y una clave de respaldo que se saca de la clave del elemento en el mapa de recolectores
  #se ejecuta solo si la sublista es una lista y se utiliza solo cuando la coleccion de recolectores es un mapa, genera un nuevo mapa
  #si la coleccion que le llega es un mapa pasa a la funcion de abajo
  defp normalizar_recolector(sublista, clave_respaldo) when is_list(sublista) do
    %{
      #:codigo es igual al dato del indice 0 de la sublita del recolector, si es nulo utiliza la clave de el elemento en el mapa de recolectores
      codigo: Enum.at(sublista, 0, clave_respaldo),
      #:nombre es igual al dato del indice 1 de la sublita del recolector
      nombre: Enum.at(sublista, 1),
      #:alimentacion es igual al dato del indice 2 de la sublita del recolector, si es nulo le ponefalse por defecto
      alimentacion: Enum.at(sublista, 2, false)
    }
  end

  #si le llega un mapa, con una clave, pasa solo el mapa al metodo normalizar_recolector(mapa)
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

  # Cuando el pesaje individual ya es un mapa
  defp normalizar_pesaje(mapa) when is_map(mapa), do: mapa

  defp normalizar_pesaje(_), do: %{}

  # Cuando el pesaje viene en un Mapa exterior
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
  Lee un entero de consola una sola vez. Retorna el número si es válido o un mensaje de error.
  """
def leer_entero(mensaje) do
  mensaje
  |> leer_string()
  |> case do
    {numero, ""} ->
      numero

    _ ->
      IO.puts(" Error: Debe ingresar un número entero válido.")[cite: 1]
      {:error, :entrada_invalida}
  end
end

  @doc """
  Lee un número flotante de consola una sola vez. Retorna el número si es válido o un mensaje de error.
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
            {:error, :entrada_invalida}
        end
    end
  end

  @doc """
  Muestra una lista de reportes en consola separándolos con pausas.
  """
  def mostrar_reportes(lista_reportes) when is_list(lista_reportes) do
    Enum.each(lista_reportes, fn reporte ->
      IO.puts(inspect(reporte, pretty: true))
      pausar()
    end)
  end

  @doc """
  Solicita y captura los datos de un pesaje adicional desde la consola.
  Retorna una tupla `{:ok, %{...}}` o `{:error, :formato_invalido}`.
  """
  def capturar_pesaje_manual do
    IO.puts("--- REGISTRO DE PESAJE ADICIONAL ---")

    cadena = leer_string("Ingrese pesaje (recolector;lote;dia;kilos;verdes) o ENTER para omitir:\n> ")

    if cadena == "" do
      {:ok, nil}
    else
      parsear_linea_pesaje(cadena)
    end
  end

defp parsear_linea_pesaje(cadena) do
  partes = String.split(cadena, ";") |> Enum.map(fn elemento -> String.trim(elemento) end)

  case partes do
    [rec, lote, dia_str, kilos_str, verdes_str] ->
      with {dia, ""} <- Integer.parse(dia_str),
           {kilos, ""} <- parse_float_or_int(kilos_str),
           {verdes, ""} <- parse_float_or_int(verdes_str) do
        {:ok, %{recolector: rec, lote: lote, dia: dia, kilos: kilos, verdes: verdes}}
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
      _ -> Integer.parse(string)
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
