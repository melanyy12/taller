defmodule Limpieza do
  @stopwords ~w(el la los las de del y a en un una por para con que es fue muy lo al se me mi)

  # Quita tildes sin dañar palabras
  defp quitar_tildes(texto) do
    texto
    |> String.replace("á", "a")
    |> String.replace("é", "e")
    |> String.replace("í", "i")
    |> String.replace("ó", "o")
    |> String.replace("ú", "u")
    |> String.replace("Á", "A")
    |> String.replace("É", "E")
    |> String.replace("Í", "I")
    |> String.replace("Ó", "O")
    |> String.replace("Ú", "U")
  end

  def limpiar(%{id: id, texto: texto}) do
    :timer.sleep(Enum.random(5..15))

    limpio =
      texto
      |> String.downcase()
      |> quitar_tildes()
      |> String.replace(~r/[^a-z0-9\s]/, "")  # quita signos
      |> String.split()
      |> Enum.reject(&(&1 in @stopwords))
      |> Enum.join(" ")

    IO.puts(" Review ##{id} limpia: #{limpio}...")

    %{id: id, resumen: limpio}
  end
end

defmodule Pipeline do
  def ejecutar() do
    reseñas = [
      %{id: 1, texto: "el Café está excelente, pero servicio lentísimo!"},
      %{id: 2, texto: "Me encantó el ambiente, música agradable."},
      %{id: 3, texto: "Demasiado caro para lo que ofrecen. No volvería."},
      %{id: 4, texto: "Lugar bonito pero comida regular."},
      %{id: 5, texto: "Excelente atención, volveré con mis amigos."}
    ]

    IO.puts("\n=== LIMPIEZA SECUENCIAL ===")
    {t1, res1} = :timer.tc(fn -> Enum.map(reseñas, &Limpieza.limpiar/1) end)
    IO.puts("Tiempo total (secuencial): #{div(t1, 1000)} ms")

    IO.puts("\n=== LIMPIEZA CONCURRENTE ===")
    {t2, res2} = :timer.tc(fn ->
      reseñas
      |> Enum.map(&Task.async(fn -> Limpieza.limpiar(&1) end))
      |> Enum.map(&Task.await/1)
    end)
    IO.puts("Tiempo total (concurrente): #{div(t2, 1000)} ms")

    IO.puts("\n=== RESÚMENES GENERADOS ===")
    Enum.each(res2, fn %{id: id, resumen: resumen} ->
      IO.puts("Review ##{id}: #{resumen}")
    end)

    IO.puts("\n Speedup (secuencial / concurrente) = #{Float.round(t1 / t2, 2)}x")
  end
end

Pipeline.ejecutar()
