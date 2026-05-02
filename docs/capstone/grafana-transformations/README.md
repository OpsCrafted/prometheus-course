# Grafana Transformations: Counter to Rate

## The Problem

Prometheus counters only go up. A counter like `http_requests_total` starts at 0 when your
application boots and increments with every request — forever. It never decreases (except on
process restart, which resets it to 0).

This creates a visualization problem:

- Raw counter on a graph: a line that climbs from 0 to 500,000 over several days
- What you actually want to see: how many requests are arriving *right now*, per second

A counter value of 847,293 tells you nothing useful at a glance. A rate of 142 req/sec tells you
exactly how busy your service is. Grafana panels showing raw counters are nearly useless for
operational dashboards — you need the rate of change, not the accumulated total.

The solution is the PromQL `rate()` function, which calculates the per-second average increase of
a counter over a sliding time window. This guide shows two ways to apply that transformation.

---

## Setup

**Prerequisites before starting:**

- Grafana is running and accessible (default: `http://localhost:3000`)
- Prometheus is running and scraping your application (default: `http://localhost:9090`)
- Your application is exposing `http_requests_total` (or a similar counter metric)
- Traffic is flowing so the counter is actively incrementing

**Verify your counter is collecting data** by opening Prometheus at `http://localhost:9090` and
running this query in the expression browser:

```
http_requests_total{endpoint="/api/checkout"}
```

You should see one or more time series with numeric values. If the result is empty, check that
your application is running and Prometheus is scraping it successfully before continuing.

---

## Step-by-Step: Counter to Rate Transformation

Two approaches are shown below. **Approach A is recommended** for almost all cases — it is
simpler and more performant. Approach B is useful in specific situations where you cannot modify
the PromQL query.

---

### Approach A: Rate in the PromQL Query (Recommended)

This approach applies `rate()` directly in the Prometheus query. Grafana receives pre-computed
rate data and simply draws the graph.

---

#### Step 1: Add a Panel to Your Dashboard

Open your dashboard in Grafana. Click the **Add** button in the top-right toolbar and select
**Visualization**. A new empty panel editor opens.

*What you will see:* A blank panel with a query editor at the bottom. The visualization area
shows "No data" until a query is entered.

---

#### Step 2: Enter the Raw Counter Query

In the query editor (the **Metrics browser** field under the **Query** tab), type:

```
http_requests_total{endpoint="/api/checkout"}
```

Click **Run query** (or press Shift+Enter).

*What you will see:* A graph where one or more lines climb steadily upward from left to right.
The Y-axis shows large absolute numbers (e.g., 0 to 800,000+). The lines never dip — they only
rise. This is the raw counter. It is technically correct but useless for monitoring request
throughput at a glance.

> **Why this matters:** This step lets you see the raw counter data before transformation. It
> confirms your metric is being scraped and gives you a baseline to compare against after
> applying `rate()`.

---

#### Step 3: Apply rate() in the PromQL Query

Replace the query in the metrics browser with:

```
rate(http_requests_total{endpoint="/api/checkout"}[5m])
```

Click **Run query**.

*What you will see:* The graph changes completely. Instead of a climbing line, you now see a
relatively flat line (with peaks and troughs) showing values between 0 and perhaps 200. The
Y-axis unit is now requests per second. Spikes correspond to traffic bursts; drops correspond to
quiet periods.

> **Why `[5m]`?** The `[5m]` is the range window — Prometheus looks back 5 minutes and computes
> the average per-second increase over that window. A shorter window (e.g., `[1m]`) reacts
> faster to changes but is more jagged. A longer window (e.g., `[15m]`) is smoother but slower
> to reflect real changes. 5 minutes is a sensible default for most dashboards.

> **Why this matters:** `rate()` handles counter resets automatically. If your application
> restarts and the counter drops back to 0, `rate()` accounts for that and does not show a
> negative spike. This is the correct tool for counter metrics.

---

#### Step 4: Set the Y-Axis Unit

In the right-hand panel options, navigate to **Standard options > Unit**. Search for and select
**requests/sec** (under the "Throughput" category) or type `reqps` in the unit search box.

*What you will see:* The Y-axis labels now read "142 req/s" instead of raw numbers. Hover
tooltips also show the unit.

> **Why this matters:** Without a unit label, a viewer cannot tell whether the Y-axis represents
> bytes, milliseconds, or requests. Units make dashboards self-documenting.

---

#### Step 5: Add a Meaningful Title and Save

Click the panel title field at the top of the panel editor (it may say "Panel Title") and rename
it to something like:

```
Checkout Requests — Rate (req/sec)
```

Click **Apply** to close the panel editor, then click the **Save dashboard** icon (floppy disk)
in the top-right toolbar and confirm.

*What you will see:* Your dashboard now contains a panel showing the live request rate for the
`/api/checkout` endpoint. The graph updates automatically as Grafana auto-refreshes.

---

### Approach B: Grafana Transform on a Raw Counter Metric

Use this approach when you are working with a pre-existing data source, a shared dashboard, or a
situation where modifying the PromQL query is not possible (e.g., a locked template or a
third-party integration).

Grafana's **Transformations** tab lets you post-process query results inside Grafana before
rendering them. However, note the important limitation stated at the end of this section.

---

#### Step 1: Open or Create a Panel with the Raw Counter Query

Start with a panel that has the raw counter query:

```
http_requests_total{endpoint="/api/checkout"}
```

Run it and confirm you see the climbing counter line (as described in Approach A, Step 2).

---

#### Step 2: Open the Transform Tab

At the top of the panel editor, you will see three tabs: **Query**, **Transform data**, and
**Alert**. Click **Transform data**.

*What you will see:* An empty transformations list with an **Add transformation** button and a
search box for finding transformation types.

---

#### Step 3: Add the "Prepare time series" Transformation (if needed)

If your query returns multiple time series (one per label combination), click **Add
transformation** and select **Prepare time series**. In the options that appear, set **Format**
to **Multi-frame time series**.

*What you will see:* The transformation appears in the list. This step normalizes the data
format so subsequent transformations work correctly on each series.

> **Why this matters:** Some Grafana transformations expect a specific data frame format. This
> step ensures compatibility, especially when the query returns multiple label combinations.

---

#### Step 4: Understand the Grafana Transform Limitation

Click **Add transformation** again and search for **Math**. Select it and inspect the
**Expression** field.

You will find that Grafana's Math transformation operates on current field values — not on the
time-series derivative that `rate()` computes in Prometheus. There is no built-in
"calculate rate from counter" transformation in Grafana 10.x. The Math and **Calculate field**
transforms can scale or offset values but cannot compute a true per-second derivative across
time.

**The practical workaround for Approach B** is to use a secondary hidden query within the same
panel:

1. In the **Query** tab, click **Add query** (the `+` button below your existing query).
2. Label the first query `A` (raw counter — click the eye icon next to it to hide it from the
   visualization).
3. In query `B`, enter the rate version:
   ```
   rate(http_requests_total{endpoint="/api/checkout"}[5m])
   ```
4. In the **Transform data** tab, add a **Filter by name** transformation if you need to
   explicitly control which series are visible.

*What you will see:* The panel displays only the rate line (query B), while the raw counter
(query A) is hidden but still available for reference or alerting rules.

> **Why this matters:** This pattern is useful when you want to preserve the raw counter for
> alerting (e.g., alert when the counter stops incrementing, indicating the service stopped
> handling requests) while showing only the rate to dashboard viewers.

---

#### Step 5: Save the Dashboard

Click **Apply**, then save the dashboard as described in Approach A, Step 5.

---

## Side-by-Side Comparison

| | Approach A | Approach B |
|---|---|---|
| **Method** | `rate()` in PromQL | Secondary hidden query + panel filter |
| **Complexity** | Low | Medium |
| **Performance** | Optimal (computed at Prometheus) | Slightly higher (extra query) |
| **Use when** | You control the query | Query is locked or shared |
| **Handles counter resets** | Yes (built into `rate()`) | Yes (built into `rate()`) |
| **Recommended** | Yes | Only when Approach A is not possible |

---

## Expected Final Result

After completing either approach, your Grafana panel should show:

- A time-series graph with values between 0 and a few hundred (depending on your traffic load)
- A Y-axis labeled in req/s or requests per second
- A line that reflects actual traffic patterns — rising during load tests, flat during idle
  periods, and spiking during traffic bursts
- No perpetually climbing line

If you run a load test against your application while watching this panel, you will see the rate
line spike immediately and then return to baseline when the test ends. This is the correct
behavior and confirms the transformation is working.

---

## Common Mistakes

**Using `increase()` instead of `rate()`**
`increase()` returns the total increase over the window, not a per-second rate. It is useful for
counting events per interval (e.g., errors per 5 minutes) but produces values that scale with
your window size. Use `rate()` when you want req/sec regardless of the window length.

**Window too short for scrape interval**
If your Prometheus scrape interval is 15s, using `[30s]` as a window gives only 2 data points —
too few for a statistically meaningful rate. The rule of thumb: the range window should be at
least 4x the scrape interval. With a 15s scrape interval, use `[1m]` minimum; `[5m]` is safer.

**Forgetting to set units in the panel**
The graph will still be correct, but Y-axis numbers without units confuse viewers. Always set
the Grafana unit to match what the metric represents.

**Applying rate() to a gauge metric**
`rate()` is only meaningful for counters. If you have a gauge metric (a value that goes up and
down freely), `rate()` will produce meaningless or misleading results. Confirm your metric type
in the Prometheus expression browser — the metadata line will show `# TYPE metric_name counter`
or `# TYPE metric_name gauge`.
