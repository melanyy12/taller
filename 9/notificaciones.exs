defmodule Notificaciones do
  # Simula el envío de una notificación según su canal
  def enviar(%{canal: canal, usuario: usuario, plantilla: plantilla}) do
    tiempo =
      case canal do
        :email -> 100
        :sms -> 80
        :push -> 60
        _ -> 50
      end

    :timer.sleep(tiempo)
    IO.puts(" Enviada a #{usuario} (canal #{canal}) con plantilla '#{plantilla}' [#{tiempo} ms]")
    {usuario, canal}
  end
end

defmodule Envio do
  def ejecutar() do
    notificaciones = [
      %{usuario: "Ana", canal: :email, plantilla: "bienvenida"},
      %{usuario: "Luis", canal: :sms, plantilla: "recordatorio"},
      %{usuario: "Marta", canal: :push, plantilla: "promocion"},
      %{usuario: "Carlos", canal: :email, plantilla: "factura"},
      %{usuario: "Sofia", canal: :push, plantilla: "alerta"}
    ]

    # === PROCESO SECUENCIAL ===
    IO.puts("\n=== ENVÍO SECUENCIAL ===")
    {t1, _} = :timer.tc(fn ->
      Enum.each(notificaciones, &Notificaciones.enviar/1)
    end)
    IO.puts("Tiempo total (secuencial): #{div(t1, 1000)} ms")

    # === PROCESO CONCURRENTE ===
    IO.puts("\n=== ENVÍO CONCURRENTE ===")
    {t2, _} = :timer.tc(fn ->
      notificaciones
      |> Enum.map(&Task.async(fn -> Notificaciones.enviar(&1) end))
      |> Enum.map(&Task.await/1)
    end)
    IO.puts("Tiempo total (concurrente): #{div(t2, 1000)} ms")

    # === RESULTADOS ===
    speedup = Float.round(t1 / t2, 2)
    IO.puts("\n Speedup (secuencial / concurrente) = #{speedup}x\n")
  end
end

Envio.ejecutar()
