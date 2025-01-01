defmodule TaskManager do
  use GenServer
  require Logger

  # Client API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def add_task(title, details) do
    GenServer.call(__MODULE__, {:add_task, title, details})
  end

  def complete_task(task_id) do
    GenServer.call(__MODULE__, {:complete_task, task_id})
  end

  def get_tasks(filter \\ :all) do
    GenServer.call(__MODULE__, {:get_tasks, filter})
  end

  def assign_task(task_id, assignee) do
    GenServer.call(__MODULE__, {:assign_task, task_id, assignee})
  end

  # Server Callbacks

  @impl true
  def init(_opts) do
    {:ok, %{tasks: %{}, completed_tasks: %{}, task_counter: 0}}
  end

  @impl true
  def handle_call({:add_task, title, details}, _from, state) do
    task_id = state.task_counter + 1
    task = %{
      id: task_id,
      title: title,
      details: details,
      status: :pending,
      assignee: nil,
      created_at: DateTime.utc_now(),
      completed_at: nil
    }

    new_state = %{
      state |
      tasks: Map.put(state.tasks, task_id, task),
      task_counter: task_id
    }

    {:reply, {:ok, task}, new_state}
  end

  @impl true
  def handle_call({:complete_task, task_id}, _from, state) do
    case Map.get(state.tasks, task_id) do
      nil ->
        {:reply, {:error, :task_not_found}, state}

      task ->
        completed_task = %{task |
          status: :completed,
          completed_at: DateTime.utc_now()
        }

        new_state = %{
          state |
          tasks: Map.delete(state.tasks, task_id),
          completed_tasks: Map.put(state.completed_tasks, task_id, completed_task)
        }

        {:reply, {:ok, completed_task}, new_state}
    end
  end

  @impl true
  def handle_call({:get_tasks, filter}, _from, state) do
    tasks = case filter do
      :all -> Map.values(state.tasks)
      :completed -> Map.values(state.completed_tasks)
      :pending -> Map.values(state.tasks) |> Enum.filter(&(&1.status == :pending))
      {:assignee, assignee} ->
        Map.values(state.tasks)
        |> Enum.filter(&(&1.assignee == assignee))
    end

    {:reply, tasks, state}
  end

  @impl true
  def handle_call({:assign_task, task_id, assignee}, _from, state) do
    case Map.get(state.tasks, task_id) do
      nil ->
        {:reply, {:error, :task_not_found}, state}

      task ->
        updated_task = %{task | assignee: assignee}
        new_state = %{state | tasks: Map.put(state.tasks, task_id, updated_task)}
        {:reply, {:ok, updated_task}, new_state}
    end
  end

  # Helper Functions

  def format_task_summary(tasks) when is_list(tasks) do
    tasks
    |> Enum.map(fn task ->
      %{
        id: task.id,
        title: task.title,
        status: task.status,
        assignee: task.assignee
      }
    end)
  end

  def calculate_metrics(tasks) do
    total = length(tasks)
    completed = Enum.count(tasks, & &1.status == :completed)
    pending = total - completed

    %{
      total_tasks: total,
      completed_tasks: completed,
      pending_tasks: pending,
      completion_rate: if(total > 0, do: completed / total * 100, else: 0)
    }
  end
end
{:ok, _pid} = TaskManager.start_link()
{:ok, task} = TaskManager.add_task("Training Session", %{date: ~D[2025-02-01]})
TaskManager.assign_task(task.id, "trainer@example.com")
