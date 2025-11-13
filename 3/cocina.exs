defmodule Orden do
  defstruct [:id, :item, :prep_ms]
end

defmodule Cocina do
  # Simula la preparación de una orden
  def preparar(%Orden{id: id, item: item, prep_ms: t}) do
    :timer.sleep(t)  # simula el tiempo de preparación
    IO.puts(" Orden ##{id} - #{item} lista en #{t} ms")
    {id, item, t}
  end

  # Procesa las órdenes una por una
  def pipeline_secuencial(ordenes) do
    Enum.map(ordenes, &preparar/1)
  end

  # Procesa todas las órdenes en paralelo (concurrente)
  def pipeline_concurrente(ordenes) do
    ordenes
    |> Enum.map(fn o -> Task.async(fn -> preparar(o) end) end)
    |> Task.await_many()
  end

  # Lista de órdenes de ejemplo
  def lista_ordenes do
    [
      %Orden{id: 1, item: "Capuchino", prep_ms: 800},
      %Orden{id: 2, item: "Té verde", prep_ms: 600},
      %Orden{id: 3, item: "Latte", prep_ms: 1000},
      %Orden{id: 4, item: "Sandwich", prep_ms: 1200},
      %Orden{id: 5, item: "Jugo natural", prep_ms: 700}
    ]
  end

  # Función principal
  def iniciar do
    ordenes = lista_ordenes()

    IO.puts("\n=== PIPELINE SECUENCIAL ===")
    {t1, tickets1} = :timer.tc(fn -> pipeline_secuencial(ordenes) end)
    IO.puts("Tiempo total (secuencial): #{div(t1, 1000)} ms")

    IO.puts("\n=== PIPELINE CONCURRENTE ===")
    {t2, tickets2} = :timer.tc(fn -> pipeline_concurrente(ordenes) end)
    IO.puts("Tiempo total (concurrente): #{div(t2, 1000)} ms") 

    IO.puts("\n=== TICKETS GENERADOS ===")
    Enum.each(tickets2, fn {id, item, _t} ->
      IO.puts("Ticket ##{id} - #{item}")
    end)

    speedup = Float.round(t1 / t2, 2)
    IO.puts("\n Speedup (secuencial / concurrente) = #{speedup}x\n")
  end
end

Cocina.iniciar()
