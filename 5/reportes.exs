defmodule Reporte do
  # Simula generación de reporte para una sucursal
  def generar(%{id: id, ventas_diarias: ventas}) do
    :timer.sleep(Enum.random(50..120))

    total = Enum.sum(Enum.map(ventas, fn {_item, v} -> v end))
    promedio = Float.round(total / length(ventas), 2)
    top_items = ventas |> Enum.sort_by(fn {_item, v} -> -v end) |> Enum.take(3)

    IO.puts(" Reporte listo Sucursal #{id}: total #{total}, promedio #{promedio}")

    %{
      id: id,
      total: total,
      promedio: promedio,
      top_items: top_items
    }
  end
end

defmodule Pipeline do
  def ejecutar() do
    sucursales = [
      %{id: 1, ventas_diarias: [{"Café", 1200}, {"Pan", 800}, {"Leche", 950}, {"Galletas", 600}]},
      %{id: 2, ventas_diarias: [{"Arepa", 1000}, {"Jugo", 900}, {"Cereal", 750}, {"Yogurt", 650}]},
      %{id: 3, ventas_diarias: [{"Sandwich", 1300}, {"Café", 1100}, {"Té", 700}, {"Agua", 500}]},
      %{id: 4, ventas_diarias: [{"Pan", 950}, {"Leche", 890}, {"Huevos", 970}, {"Queso", 1200}]},
      %{id: 5, ventas_diarias: [{"Pizza", 2100}, {"Refresco", 1200}, {"Postre", 800}, {"Agua", 300}]}
    ]

    # SECUNCIAL
    IO.puts("\n=== GENERACIÓN SECUENCIAL ===")
    {t1, rep1} = :timer.tc(fn -> Enum.map(sucursales, &Reporte.generar/1) end)
    IO.puts("Tiempo total (secuencial): #{div(t1, 1000)} ms")

    # CONCURRENTE
    IO.puts("\n=== GENERACIÓN CONCURRENTE ===")
    {t2, rep2} =
      :timer.tc(fn ->
        sucursales
        |> Enum.map(&Task.async(fn -> Reporte.generar(&1) end))
        |> Enum.map(&Task.await/1)
      end)

    IO.puts("Tiempo total (concurrente): #{div(t2, 1000)} ms")

    # RESUMEN FINAL
    IO.puts("\n=== RESÚMENES POR SUCURSAL ===")
    Enum.each(rep2, fn %{id: id, total: total, promedio: prom, top_items: top} ->
      top_nombres = Enum.map(top, fn {item, _v} -> item end) |> Enum.join(", ")
      IO.puts("Sucursal #{id}: Total #{total}, Promedio #{prom}, Top: #{top_nombres}")
    end)

    IO.puts("\n Speedup (secuencial / concurrente) = #{Float.round(t1 / t2, 2)}x\n")
  end
end

Pipeline.ejecutar()
