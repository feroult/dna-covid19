import matplotlib
import matplotlib.pyplot as plt
import numpy as np
import math

# CASE
#      WHEN SUM(c.cases) = 0 THEN 0
#      ELSE LOG(SUM(c.cases))
# END AS Y

MAX_X = 30


def abline(slope, intercept, label):
    """Plot a line from slope and intercept"""
    x_vals = np.array(list(range(0, MAX_X+1)))
    y_vals = np.round(math.e ** (intercept + slope * x_vals), 0)
    print(x_vals)
    print(y_vals)
    plt.plot(x_vals, y_vals, '--', label=label)


axes = plt.axes()
# axes.set_ylim([0, 1000])
axes.set_xlim([0, MAX_X+1])

# abline(0.26919211676124427, 2.815588415394319, 'US')
abline(0.27720642643099297, 2.6593449376999487, 'Brazil')
# abline(0.34032143885575084, 1.2899922585751407, 'Turkey')
# abline(0.3127348344391668, 2.283156034723741, 'Brazil-LN')
# abline(0.13581901289585707, 0.9915620672046301, 'Brazil-10')

plt.legend(loc="upper left")
plt.show()
