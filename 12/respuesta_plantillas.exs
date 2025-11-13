defmodule Render do
  # Simula el renderizado de una mini plantilla
  def render(%{id: id, nombre: tpl, vars: vars}) do
    :timer.sleep(String.length(tpl) * 2)

    html =
      Enum.reduce(vars, tpl, fn {k, v}, acc ->
        String.replace(acc, "{{#{k}}}", to_string(v))
      end)

    IO.puts(" Render lista plantilla ##{id}")
    {id, html}
  end
end

defmodule Pipeline do
  def ejecutar() do
    plantillas = [
      %{id: 1, nombre: "<h1>Hola {{nombre}}</h1>", vars: %{nombre: "Sofía"}},
      %{id: 2, nombre: "<p>Bienvenido {{user}}, tu saldo es {{saldo}} USD</p>", vars: %{user: "Alex", saldo: 53.25}},
      #  Aquí se evita el conflicto con #{...} agregando un espacio
      %{id: 3, nombre: "<div>Pedido # {{id_pedido}} enviado a {{direccion}}</div>", vars: %{id_pedido: 9123, direccion: "Calle 45"}},
      %{id: 4, nombre: "<footer>© {{anio}} MiEmpresa</footer>", vars: %{anio: 2025}},
      %{id: 5, nombre: "<b>{{producto}}</b> - Precio: ${{precio}}", vars: %{producto: "Café Premium", precio: 8900}}
    ]

    # === SECUENCIAL ===
    IO.puts("\n=== RENDER SECUENCIAL ===")
    {t1, _renders_seq} = :timer.tc(fn ->
      Enum.map(plantillas, &Render.render/1)
    end)
    IO.puts("Tiempo total (secuencial): #{div(t1, 1000)} ms")

    # === CONCURRENTE ===
    IO.puts("\n=== RENDER CONCURRENTE ===")
    {t2, renders_conc} = :timer.tc(fn ->
      plantillas
      |> Enum.map(&Task.async(fn -> Render.render(&1) end))
      |> Enum.map(&Task.await/1)
    end)
    IO.puts("Tiempo total (concurrente): #{div(t2, 1000)} ms")

    # === RESULTADOS ===
    IO.puts("\n=== RESULTADOS DE RENDER ===")
    Enum.each(renders_conc, fn {id, html} ->
      IO.puts(" Plantilla ##{id}: #{html}")
    end)

    # === SPEEDUP ===
    speedup = Float.round(t1 / t2, 2)
    IO.puts("\n Speedup (secuencial / concurrente) = #{speedup}x\n")
  end
end

Pipeline.ejecutar()
