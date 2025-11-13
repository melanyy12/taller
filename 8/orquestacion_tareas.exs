defmodule Backoffice do
  # Simula la ejecución de una tarea con diferentes tiempos según el tipo
  def ejecutar(tarea) do
    tiempo =
      case tarea do
        :reindex -> 120
        :purge_cache -> 80
        :build_sitemap -> 100
        :backup_db -> 150
        :clean_temp -> 60
        _ -> 50
      end

    :timer.sleep(tiempo)
    IO.puts(" OK tarea #{tarea} (#{tiempo} ms)")
    tarea
  end
end

defmodule Orquestador do
  def ejecutar() do
    tareas = [:reindex, :purge_cache, :build_sitemap, :backup_db, :clean_temp]

    # === SECUNCIAL ===
    IO.puts("\n=== ORQUESTACIÓN SECUENCIAL ===")
    {t1, _} = :timer.tc(fn ->
      Enum.each(tareas, &Backoffice.ejecutar/1)
    end)
    IO.puts("Tiempo total (secuencial): #{div(t1, 1000)} ms")

    # === CONCURRENTE ===
    IO.puts("\n=== ORQUESTACIÓN CONCURRENTE ===")
    {t2, _} = :timer.tc(fn ->
      tareas
      |> Enum.map(&Task.async(fn -> Backoffice.ejecutar(&1) end))
      |> Enum.map(&Task.await/1)
    end)
    IO.puts("Tiempo total (concurrente): #{div(t2, 1000)} ms")

    # === RESULTADOS ===
    speedup = Float.round(t1 / t2, 2)
    IO.puts("\n Speedup (secuencial / concurrente) = #{speedup}x\n")
  end
end

Orquestador.ejecutar()
