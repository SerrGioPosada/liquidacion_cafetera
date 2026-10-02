## Integrantes del Grupo
# Sergio Posada Garcia
# Jhonatan Perilla Betancur
# Sara Benjumea Gallego

defmodule Datos do
  @moduledoc """
  Módulo encargado exclusivamente de proveer la información base de la finca.
  Contiene las listas de recolectores, lotes y pesajes registrados.
  """

  @doc """
  Devuelve la lista de recolectores de la finca.
  Al menos 10 recolectores, con mínimo 4 que tienen descuento de alimentación.
  """
  def recolectores do
    [
      %{codigo: "R01", nombre: "Luz Marina Ospina", alimentacion: true},
      %{codigo: "R02", nombre: "Jhon Fredy Castaño", alimentacion: false},
      %{codigo: "R03", nombre: "Dora Cardona", alimentacion: true},
      %{codigo: "R04", nombre: "Wilson Arango", alimentacion: false},
      %{codigo: "R05", nombre: "Carlos Alberto Gómez", alimentacion: true},
      %{codigo: "R06", nombre: "Ana Milena Ríos", alimentacion: false},
      %{codigo: "R07", nombre: "Jorge Eliécer Morales", alimentacion: true},
      %{codigo: "R08", nombre: "Claudia Patricia Tobón", alimentacion: false},
      %{codigo: "R09", nombre: "Andrés Felipe Marín", alimentacion: false},
      %{codigo: "R10", nombre: "Martha Lucía Gutiérrez", alimentacion: true}
    ]
  end

  @doc """
  Devuelve la lista de lotes de la finca.
  Al menos 4 lotes con sus respectivas hectáreas.
  """
  def lotes do
    [
      %{id: "L1", nombre: "El Mirador", hectareas: 2.5},
      %{id: "L2", nombre: "La Cañada", hectareas: 1.5},
      %{id: "L3", nombre: "Buenavista", hectareas: 3.0},
      %{id: "L4", nombre: "La Esperanza", hectareas: 2.0}
    ]
  end

  @doc """
  Devuelve la lista de pesajes registrados por el mayordomo.
  Contiene 80 pesajes válidos distribuidos en los 6 días y al menos 2
  pesajes inválidos por cada motivo de rechazo.
  """
  def pesajes do
    [
      # --- DÍA 1 (VÁLIDOS) ---
      %{recolector: "R01", lote: "L1", dia: 1, kilos: 70.0, verdes: 1.5},
      %{recolector: "R01", lote: "L2", dia: 1, kilos: 55.0, verdes: 6.0},
      %{recolector: "R02", lote: "L1", dia: 1, kilos: 100.0, verdes: 2.0},
      %{recolector: "R02", lote: "L3", dia: 1, kilos: 45.0, verdes: 3.0},
      %{recolector: "R03", lote: "L2", dia: 1, kilos: 65.0, verdes: 5.0},
      %{recolector: "R03", lote: "L3", dia: 1, kilos: 60.0, verdes: 4.0},
      %{recolector: "R04", lote: "L4", dia: 1, kilos: 80.0, verdes: 1.0},
      %{recolector: "R05", lote: "L1", dia: 1, kilos: 75.0, verdes: 2.5},
      %{recolector: "R05", lote: "L4", dia: 1, kilos: 50.0, verdes: 7.0},
      %{recolector: "R06", lote: "L2", dia: 1, kilos: 90.0, verdes: 3.5},
      %{recolector: "R07", lote: "L3", dia: 1, kilos: 110.0, verdes: 1.8},
      %{recolector: "R08", lote: "L1", dia: 1, kilos: 85.0, verdes: 4.2},
      %{recolector: "R09", lote: "L4", dia: 1, kilos: 95.0, verdes: 2.0},
      %{recolector: "R10", lote: "L2", dia: 1, kilos: 70.0, verdes: 8.0},

      # --- DÍA 2 (VÁLIDOS) ---
      %{recolector: "R01", lote: "L1", dia: 2, kilos: 90.0, verdes: 12.0},
      %{recolector: "R02", lote: "L2", dia: 2, kilos: 60.5, verdes: 4.0},
      %{recolector: "R02", lote: "L3", dia: 2, kilos: 65.0, verdes: 5.0},
      %{recolector: "R03", lote: "L1", dia: 2, kilos: 85.0, verdes: 2.5},
      %{recolector: "R03", lote: "L2", dia: 2, kilos: 50.0, verdes: 3.0},
      %{recolector: "R04", lote: "L3", dia: 2, kilos: 70.0, verdes: 2.0},
      %{recolector: "R04", lote: "L4", dia: 2, kilos: 55.0, verdes: 3.0},
      %{recolector: "R05", lote: "L2", dia: 2, kilos: 80.0, verdes: 6.0},
      %{recolector: "R05", lote: "L3", dia: 2, kilos: 45.0, verdes: 1.5},
      %{recolector: "R06", lote: "L4", dia: 2, kilos: 100.0, verdes: 4.0},
      %{recolector: "R07", lote: "L1", dia: 2, kilos: 60.0, verdes: 3.0},
      %{recolector: "R07", lote: "L4", dia: 2, kilos: 65.0, verdes: 2.2},
      %{recolector: "R08", lote: "L2", dia: 2, kilos: 75.0, verdes: 5.5},
      %{recolector: "R09", lote: "L3", dia: 2, kilos: 110.0, verdes: 1.0},
      %{recolector: "R10", lote: "L1", dia: 2, kilos: 80.0, verdes: 9.0},

      # --- DÍA 3 (VÁLIDOS) ---
      %{recolector: "R01", lote: "L4", dia: 3, kilos: 60.0, verdes: 3.0},
      %{recolector: "R02", lote: "L3", dia: 3, kilos: 110.0, verdes: 1.0},
      %{recolector: "R03", lote: "L2", dia: 3, kilos: 95.0, verdes: 8.0},
      %{recolector: "R03", lote: "L1", dia: 3, kilos: 40.0, verdes: 0.0},
      %{recolector: "R04", lote: "L1", dia: 3, kilos: 85.0, verdes: 4.0},
      %{recolector: "R05", lote: "L4", dia: 3, kilos: 90.0, verdes: 3.2},
      %{recolector: "R06", lote: "L3", dia: 3, kilos: 75.0, verdes: 2.1},
      %{recolector: "R06", lote: "L2", dia: 3, kilos: 50.0, verdes: 4.5},
      %{recolector: "R07", lote: "L1", dia: 3, kilos: 105.0, verdes: 1.2},
      %{recolector: "R08", lote: "L4", dia: 3, kilos: 65.0, verdes: 6.0},
      %{recolector: "R09", lote: "L2", dia: 3, kilos: 80.0, verdes: 3.0},
      %{recolector: "R10", lote: "L3", dia: 3, kilos: 70.0, verdes: 11.0},

      # --- DÍA 4 (VÁLIDOS) ---
      %{recolector: "R01", lote: "L2", dia: 4, kilos: 75.0, verdes: 2.0},
      %{recolector: "R02", lote: "L1", dia: 4, kilos: 80.0, verdes: 3.0},
      %{recolector: "R02", lote: "L4", dia: 4, kilos: 50.0, verdes: 2.5},
      %{recolector: "R03", lote: "L3", dia: 4, kilos: 120.0, verdes: 1.5},
      %{recolector: "R04", lote: "L2", dia: 4, kilos: 90.0, verdes: 5.0},
      %{recolector: "R05", lote: "L1", dia: 4, kilos: 65.0, verdes: 4.0},
      %{recolector: "R05", lote: "L3", dia: 4, kilos: 60.0, verdes: 2.0},
      %{recolector: "R06", lote: "L4", dia: 4, kilos: 85.0, verdes: 1.8},
      %{recolector: "R07", lote: "L2", dia: 4, kilos: 95.0, verdes: 3.5},
      %{recolector: "R08", lote: "L1", dia: 4, kilos: 70.0, verdes: 4.0},
      %{recolector: "R09", lote: "L1", dia: 4, kilos: 75.0, verdes: 1.2},
      %{recolector: "R09", lote: "L3", dia: 4, kilos: 100.0, verdes: 2.2},
      %{recolector: "R10", lote: "L4", dia: 4, kilos: 80.0, verdes: 7.5},

      # --- DÍA 5 (VÁLIDOS) ---
      %{recolector: "R01", lote: "L3", dia: 5, kilos: 85.0, verdes: 4.0},
      %{recolector: "R01", lote: "L1", dia: 5, kilos: 40.0, verdes: 2.0},
      %{recolector: "R02", lote: "L2", dia: 5, kilos: 95.0, verdes: 1.8},
      %{recolector: "R03", lote: "L4", dia: 5, kilos: 70.0, verdes: 3.0},
      %{recolector: "R04", lote: "L1", dia: 5, kilos: 60.0, verdes: 6.0},
      %{recolector: "R04", lote: "L3", dia: 5, kilos: 65.0, verdes: 4.0},
      %{recolector: "R05", lote: "L2", dia: 5, kilos: 110.0, verdes: 2.5},
      %{recolector: "R06", lote: "L1", dia: 5, kilos: 90.0, verdes: 3.0},
      %{recolector: "R07", lote: "L4", dia: 5, kilos: 75.0, verdes: 1.0},
      %{recolector: "R07", lote: "L3", dia: 5, kilos: 50.0, verdes: 2.0},
      %{recolector: "R08", lote: "L2", dia: 5, kilos: 85.0, verdes: 5.0},
      %{recolector: "R09", lote: "L1", dia: 5, kilos: 90.0, verdes: 3.8},
      %{recolector: "R10", lote: "L3", dia: 5, kilos: 65.0, verdes: 10.5},

      # --- DÍA 6 (VÁLIDOS) ---
      %{recolector: "R01", lote: "L2", dia: 6, kilos: 90.0, verdes: 1.0},
      %{recolector: "R02", lote: "L4", dia: 6, kilos: 70.0, verdes: 3.5},
      %{recolector: "R02", lote: "L1", dia: 6, kilos: 60.0, verdes: 2.0},
      %{recolector: "R03", lote: "L3", dia: 6, kilos: 80.0, verdes: 4.0},
      %{recolector: "R04", lote: "L2", dia: 6, kilos: 100.0, verdes: 1.5},
      %{recolector: "R05", lote: "L4", dia: 6, kilos: 75.0, verdes: 3.0},
      %{recolector: "R06", lote: "L3", dia: 6, kilos: 115.0, verdes: 2.2},
      %{recolector: "R07", lote: "L1", dia: 6, kilos: 85.0, verdes: 1.9},
      %{recolector: "R08", lote: "L3", dia: 6, kilos: 70.0, verdes: 2.8},
      %{recolector: "R08", lote: "L4", dia: 6, kilos: 90.0, verdes: 4.8},
      %{recolector: "R09", lote: "L2", dia: 6, kilos: 105.0, verdes: 2.0},
      %{recolector: "R10", lote: "L1", dia: 6, kilos: 70.0, verdes: 8.5},
      %{recolector: "R10", lote: "L2", dia: 6, kilos: 60.0, verdes: 6.5},

      # --- PESAJE INVÁLIDOS (Al menos 2 por cada motivo de rechazo) ---

      # Motivo 1: :recolector_desconocido (2 casos)
      %{recolector: "R99", lote: "L1", dia: 1, kilos: 80.0, verdes: 3.0},
      %{recolector: "R50", lote: "L2", dia: 3, kilos: 65.0, verdes: 2.0},

      # Motivo 2: :lote_desconocido (2 casos)
      %{recolector: "R03", lote: "L7", dia: 2, kilos: 50.0, verdes: 2.0},
      %{recolector: "R05", lote: "L9", dia: 4, kilos: 70.0, verdes: 1.5},

      # Motivo 3: :dia_invalido (2 casos)
      %{recolector: "R04", lote: "L3", dia: 7, kilos: 90.0, verdes: 3.0},
      %{recolector: "R02", lote: "L1", dia: 0, kilos: 100.0, verdes: 2.5},

      # Motivo 4: :kilos_fuera_de_rango (2 casos)
      %{recolector: "R02", lote: "L2", dia: 3, kilos: 0.0, verdes: 4.0},
      %{recolector: "R01", lote: "L3", dia: 3, kilos: 300.0, verdes: 2.0},

      # Motivo 5: :porcentaje_invalido (2 casos)
      %{recolector: "R01", lote: "L2", dia: 3, kilos: 40.0, verdes: 130.0},
      %{recolector: "R06", lote: "L4", dia: 5, kilos: 55.0, verdes: -5.0}
    ]
  end
end
