defmodule Validador do
  #  Valida un usuario individualmente
  def validar(%{email: email, edad: edad, nombre: nombre}) do
    :timer.sleep(Enum.random(3..10))

    errores =
      []
      |> maybe_add(String.contains?(email, "@"), :email_invalido)
      |> maybe_add(edad >= 0, :edad_invalida)
      |> maybe_add(String.trim(nombre) != "", :nombre_vacio)

    resultado =
      if errores == [], do: :ok, else: {:error, errores}

    IO.puts(" Validado #{email}: #{inspect(resultado)}")

    {email, resultado}
  end

  # Función auxiliar: agrega error si la condición es falsa
  defp maybe_add(list, true, _error), do: list
  defp maybe_add(list, false, error), do: [error | list]
end

defmodule Pipeline do
  def ejecutar() do
    usuarios = [
      %{email: "ana@example.com", edad: 25, nombre: "Ana"},
      %{email: "pedroexample.com", edad: 19, nombre: "Pedro"},  # sin @
      %{email: "luis@example.com", edad: -5, nombre: "Luis"},    # edad inválida
      %{email: "sofia@example.com", edad: 30, nombre: ""},       # nombre vacío
      %{email: "carla@example.com", edad: 22, nombre: "Carla"}
    ]

    # SECUENCIAL
    IO.puts("\n=== VALIDACIÓN SECUENCIAL ===")
    {t1, res1} = :timer.tc(fn -> Enum.map(usuarios, &Validador.validar/1) end)
    IO.puts("Tiempo total (secuencial): #{div(t1, 1000)} ms")

    # CONCURRENTE
    IO.puts("\n=== VALIDACIÓN CONCURRENTE ===")
    {t2, res2} =
      :timer.tc(fn ->
        usuarios
        |> Enum.map(&Task.async(fn -> Validador.validar(&1) end))
        |> Enum.map(&Task.await/1)
      end)
    IO.puts("Tiempo total (concurrente): #{div(t2, 1000)} ms")

    # RESULTADOS
    IO.puts("\n=== RESULTADOS DE VALIDACIÓN ===")
    Enum.each(res2, fn {email, result} ->
      IO.puts("#{email} → #{inspect(result)}")
    end)

    IO.puts("\n Speedup (secuencial / concurrente) = #{Float.round(t1 / t2, 2)}x\n")
  end
end

Pipeline.ejecutar()
