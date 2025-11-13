defmodule Moderador do
  @palabras_prohibidas ["tonto", "spam", "odio", "estúpido"]
  @max_longitud 120

  def moderar(%{id: id, texto: texto}) do
    # Simula procesamiento (como revisión automática o ML)
    :timer.sleep(Enum.random(5..12))

    resultado =
      cond do
        String.length(texto) > @max_longitud ->
          :rechazado

        Enum.any?(@palabras_prohibidas, &String.contains?(String.downcase(texto), &1)) ->
          :rechazado

        String.contains?(texto, ["http", "www"]) ->
          :rechazado

        true ->
          :aprobado
      end

    IO.puts(" Comentario ##{id} → #{resultado}")
    {id, resultado}
  end
end

defmodule Pipeline do
  def ejecutar() do
    comentarios = [
      %{id: 1, texto: "Me encantó este producto! Muy útil."},
      %{id: 2, texto: "Visita mi página www.promospam.com"},
      %{id: 3, texto: "Qué tonto el que hizo esto."},
      %{id: 4, texto: "Excelente servicio, volveré a comprar."},
      %{id: 5, texto: String.duplicate("Muy bueno ", 30)} # demasiado largo
    ]

    # === SECUENCIAL ===
    IO.puts("\n=== MODERACIÓN SECUENCIAL ===")
    {t1, _} = :timer.tc(fn ->
      Enum.map(comentarios, &Moderador.moderar/1)
    end)
    IO.puts("Tiempo total (secuencial): #{div(t1, 1000)} ms")

    # === CONCURRENTE ===
    IO.puts("\n=== MODERACIÓN CONCURRENTE ===")
    {t2, _} = :timer.tc(fn ->
      comentarios
      |> Enum.map(&Task.async(fn -> Moderador.moderar(&1) end))
      |> Enum.map(&Task.await/1)
    end)
    IO.puts("Tiempo total (concurrente): #{div(t2, 1000)} ms")

    # === SPEEDUP ===
    speedup = Float.round(t1 / t2, 2)
    IO.puts("\n Speedup (secuencial / concurrente) = #{speedup}x\n")
  end
end

Pipeline.ejecutar()
