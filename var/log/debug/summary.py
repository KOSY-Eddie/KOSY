import os
import re
from operator import itemgetter

def get_stats(filepath):
    try:
        durations = []
        with open(filepath, 'r') as f:
            for line in f:
                if line.startswith('END:'):
                    # Extract duration from the END line
                    duration_match = re.match(r'END:[\d.]+ DURATION:([\d.]+)', line)
                    if duration_match:
                        durations.append(float(duration_match.group(1)))

        if durations:
            total_duration = sum(durations)
            total_calls = len(durations)
            return {
                'filepath': filepath,
                'total_duration': total_duration,
                'total_calls': total_calls,
                'avg_time': total_duration / total_calls if total_calls > 0 else 0,
                'max_time': max(durations),
                'min_time': min(durations)
            }
        return None
    except Exception as e:
        print(f"Error reading {filepath}: {str(e)}")
        return None

# Process all log files
stats = []
for root, _, files in os.walk('.'):
    for file in files:
        if file.endswith('.log'):
            filepath = os.path.join(root, file)
            result = get_stats(filepath)
            if result:
                stats.append(result)

# Sort by total duration
stats = sorted(stats, key=itemgetter('total_duration'), reverse=True)

# Generate report
report_lines = ["KOS Debug Statistics Report", "=" * 100, ""]
report_lines.append(f"{'Filepath':<50} {'Total Time':<15} {'Calls':<10} {'Avg Time':<10} {'Max Time':<10} {'Min Time':<10}")
report_lines.append("-" * 105)

for stat in stats:
    report_lines.append(f"{stat['filepath']:<50} {stat['total_duration']:<15.4f} {stat['total_calls']:<10} {stat['avg_time']:<10.4f} {stat['max_time']:<10.4f} {stat['min_time']:<10.4f}")

# Write to file
with open("debug_summary.txt", 'w') as f:
    f.write("\n".join(report_lines))

print("Report generated successfully: debug_summary.txt")
