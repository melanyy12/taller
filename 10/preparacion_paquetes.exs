defmodule Logistica do
  # Simula la preparación de un paquete (etiquetar, pesar, embalar)
  def preparar(%{id: id, peso: peso, fragil?: fragil}) do
    inicio = System.monotonic_time(:millisecond)

    # Paso 1: Etiquetar
    :timer.sleep(40)

    # Paso 2: Pesar (más tiempo si es pesado)
    if peso > 10, do: :timer.sleep(60), else: :timer.sleep(30)

    # Paso 3: Embalar (extra cuidado si es frágil)
    if fragil, do: :timer.sleep(70), else: :timer.sleep(40)

    fin = System.monotonic_time(:millisecond)
    duracion = fin - inicio

    IO.puts(" Paquete ##{id} listo en #{duracion} ms (#{if fragil, do: "frágil", else: "normal"})")
    {id, duracion}
  end
end

defmodule Pipeline do
  def ejecutar() do
    paquetes = [
      %{id: 1, peso: 5, fragil?: false},
      %{id: 2, peso: 12, fragil?: true},
      %{id: 3, peso: 8, fragil?: false},
      %{id: 4, peso: 20, fragil?: true},
      %{id: 5, peso: 3, fragil?: false}
    ]

    # === PROCESO SECUENCIAL ===
    IO.puts("\n=== PREPARACIÓN SECUENCIAL ===")
    {t1, _} = :timer.tc(fn ->
      Enum.each(paquetes, &Logistica.preparar/1)
    end)
    IO.puts("Tiempo total (secuencial): #{div(t1, 1000)} ms")

    # === PROCESO CONCURRENTE ===
    IO.puts("\n=== PREPARACIÓN CONCURRENTE ===")
    {t2, _} = :timer.tc(fn ->
      paquetes
      |> Enum.map(&Task.async(fn -> Logistica.preparar(&1) end))
      |> Enum.map(&Task.await/1)
    end)
    IO.puts("Tiempo total (concurrente): #{div(t2, 1000)} ms")

    # === RESULTADOS ===
    speedup = Float.round(t1 / t2, 2)
    IO.puts("\n Speedup (secuencial / concurrente) = #{speedup}x\n")
  end
end

Pipeline.ejecutar()
