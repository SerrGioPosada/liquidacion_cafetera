defmodule Reportes do
@moduledoc """
  Módulo de generación de reportes
  
  """
  def reporte_r1(invalidos) do
  motivos =
    invalidos
    |> Enum.map(fn {_pesaje, motivo} -> motivo end)
    |> Enum.frequencies()

  {invalidos, motivos}
  end

  def reporte_r2(validos,lotes) do

  #pesajes agrupados por lote en un mapa

  pesajes_por_lote = Enum.group_by(validos, fn pesaje -> pesaje.lote end)

  lotes
  |>Enum.map(fn lote -> procesar_lote(lote,pesajes_por_lote) end)
  |>Enum.sort_by(fn {_id, _nombre,_kilos,rendimiento} -> rendimiento end, :desc)

  end

  defp procesar_lote(%{id: id, nombre: nombre,hectareas: hectareas}, pesajes_por_lote) do
   pesajes = Map.get(pesajes_por_lote, id , [])

   kilos = Enum.reduce(pesajes, 0, fn pesaje, acumulador -> acumulador + pesaje.kilos end)

   rendimiento = calcular_rendimiento(kilos,hectareas)

   {id,nombre, kilos , rendimiento} 
  
  end

  defp calcular_rendimiento(_kilos,hectareas) when hectareas == 0 or hectareas == 0.0 do

  0.0
  end

  defp calcular_rendimiento(kilos,hectareas) do
    kilos/hectareas 
  end

  def reporte_r3(validos, meta_diaria) do
    # 1. se agrupan los mensajes por dia
    pesajes_por_dia = Enum.group_by(validos, fn pesaje -> pesaje.dia end)

    # 2. se genera el reporte en el rango
    reportes = Enum.map(1..6, fn dia ->
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



  def liquidar_recolector(recolector, pesajes, tarifa_base) do
   kilos =
     Enum.reduce(pesajes, 0.0, fn pesaje, acumulador ->
      acumulador + pesaje.kilos
     end)

   total_pesajes =
    Enum.reduce(pesajes, 0.0, fn pesaje, acumulador ->
      acumulador + valor_pesaje(pesaje, tarifa_base)
    end)

   bonificaciones = bonificacion(pesajes)
   alimentacion = descuento_alimentacion(pesajes)

   neto = total_pesajes + bonificaciones - alimentacion

   %{
    recolector: recolector.codigo,
    nombre: recolector.nombre,
    kilos: kilos,
    pesajes: total_pesajes,
    bonificaciones: bonificaciones,
    alimentacion: alimentacion,
    neto: neto
   }
  end

  def reporte_r4(recolectores, validos, tarifa_base) do
   pesajes_por_recolector =
    Enum.group_by(validos, fn pesaje ->
      pesaje.recolector
    end)

   recolectores
   |> Enum.map(fn recolector ->
    pesajes = Map.get(pesajes_por_recolector, recolector.codigo, [])

   liquidar_recolector(recolector, pesajes, tarifa_base)
   end)
   |> Enum.sort_by(fn liquidacion -> liquidacion.neto end, :desc)
   |> Enum.with_index(1)
   end

   def formato_dinero(valor) do
   "$" <> :erlang.float_to_binary(valor, decimals: 2)

   end


   def reporte_r5(validos, recolectores) do
     mejores_por_dia =
      Enum.map(1..6, fn dia ->
       mejor_del_dia(dia, validos, recolectores)
        end)

      ganadores = Enum.reduce(mejores_por_dia, [], fn resultado, acumulador -> agregar_ganadores(resultado,acumulador) end)

      veces_mejor = Enum.frequencies(ganadores)
 
      max_dias = Enum.max(Map.values(veces_mejor))

      mejores_totales = Enum.filter(veces_mejor, fn{_codigo,dias} -> dias == max_dias end)

      {mejores_por_dia, mejores_totales}

    end

    defp agregar_ganadores({_dia, :sin_pesajes_validos}, acumulador) do
      acumulador
    end

    defp agregar_ganadores({_dia,mejores}, acumulador) do
      
      nuevos_ganadores = Enum.map(mejores,fn{codigo,_kilos} -> codigo end)

      acumulador ++ nuevos_ganadores
    end
    
   defp mejor_del_dia(dia,validos,recolectores) do
     #se calculan los kilos de cada recolector
      kilos_recolectores = kilos_por_recolector(dia, validos, recolectores)

      kilos = Enum.map(kilos_recolectores, fn {_codigo, kilos} -> kilos end)

      if Enum.all?(kilos, fn kilos -> kilos == 0.0 end) do
        {dia,:sin_pesajes_validos}
      else
        maximo = Enum.max(kilos)

       mejores = Enum.filter(kilos_recolectores, fn{_codigo, kilos} -> kilos == maximo end )

       {dia,mejores}

       end
    end

  defp kilos_por_recolector(dia, validos, recolectores) do
   pesajes_por_recolector = validos
    |> Enum.filter(fn pesaje -> pesaje.dia == dia end)
    |> Enum.group_by(fn pesaje -> pesaje.recolector end)

   Enum.map(recolectores, fn recolector ->
    pesajes = Map.get(pesajes_por_recolector, recolector.codigo, [])

     kilos = Enum.reduce(pesajes, 0.0, fn pesaje, acc ->
      acc + pesaje.kilos
     end)

      {recolector.codigo, kilos}
    end)
  end

  defp pesajes_por_recolector(validos) do
    Enum.group_by(validos, fn pesaje -> pesaje.recolector end)

  end

  defp filtrar_recolectores(pesajes_por_recolector) do
    Enum.filter(pesajes_por_recolector, fn {_codigo,pesajes} -> lenght(pesajes) >=3 end)
  end

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

    verdes_ponderados = Enum.reduce(pesajes, 0.0,fn pesaje, acumulador ->
      acumulador + pesaje.verdes * pesaje.kilos end)

    kilos = Enum.reduce(pesajes, 0.0 , fn pesaje, acumulador -> acumulador + pesaje.kilos end)

    porcentaje = verdes_ponderados / kilos

    {codigo, porcentaje}

   end

   def reporte_r7(recolectores, validos,tarifa_base) do

   pesajes_por_recolector = Enum.group_by(validos,fn pesaje -> pesaje.recolector end)

   liquidaciones = Enum.map(recolectores, fn recolector -> pesajes = Map.get(pesajes_por_recolector, recolector.codigo, [])
   
    liquidar_recolector(recolector,pesajes,tarifa_base)end)

   total_pagado = Enum.reduce(liquidaciones, 0.0, fn liquidacion, acumulador -> acumulador + liquidacion.neto end)

   kilos_validos = Enum.reduce(liquidaciones, 0.0, fn liquidacion, acumulador -> acumulador + liquidacion.kilos end)

   costo_promedio = total_pagado / kilos_validos

   {total_pagado, costo_promedio}

   end

  def reporte_r8(recolectores, validos, lotes) do

   pesajes_por_recolector =
    Enum.group_by(validos, fn pesaje ->
      pesaje.recolector
    end)

   recolectores_todos_lotes =
    recolectores
    |> Enum.filter(fn recolector ->
      pesajes = Map.get(pesajes_por_recolector, recolector.codigo, [])

      Enum.all?(lotes, fn lote ->
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

