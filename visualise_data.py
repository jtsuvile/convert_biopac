import bioread
import matplotlib.pyplot as plt
fileloc = '/Users/juusu53/Documents/projects/femg/data/'
filename = 'E606_IAPS_pre'

data = bioread.read_file(fileloc + filename +'.acq')

# plt.subplot(411)
# plt.plot(data.channels[0].time_index, data.channels[0].data,
#          label='{} ({})'.format(data.channels[0].name, data.channels[0].units),
#          alpha=0.7)
# plt.plot(data.channels[1].time_index, data.channels[1].data,
#          label='{} ({})'.format(data.channels[1].name, data.channels[1].units),
#          alpha=0.7)
# plt.plot(data.channels[2].time_index, data.channels[2].data,
#          label='{} ({})'.format(data.channels[2].name, data.channels[2].units),
#          alpha=0.7)
# plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
#            ncol=3, mode="expand", borderaxespad=0.)
# plt.subplot(412)
# plt.plot(data.channels[11].time_index, data.channels[11].data,
#          label='{} ({})'.format(data.channels[11].name, data.channels[11].units),
#          alpha=0.7)
# plt.plot(data.channels[12].time_index, data.channels[12].data,
#          label='{} ({})'.format(data.channels[12].name, data.channels[12].units),
#          alpha=0.7)
# plt.plot(data.channels[13].time_index, data.channels[13].data,
#          label='{} ({})'.format(data.channels[13].name, data.channels[13].units),
#          alpha=0.7)
# plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
#            ncol=3, mode="expand", borderaxespad=0.)
# plt.subplot(413)
# for i in range(3,10):
#     plt.plot(data.channels[i].time_index, data.channels[i].data,
#              label='{} ({})'.format(data.channels[i].name, data.channels[i].units))
# plt.subplot(414)
# plt.plot(data.channels[14].time_index, data.channels[14].data,
#          label='{} ({})'.format(data.channels[14].name, data.channels[14].units))
# plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
#            ncol=3, mode="expand", borderaxespad=0.)
#
# figure = plt.gcf()
# figure.set_size_inches(10, 12)
# plt.savefig('all_channels.png')
# #plt.show()

fig = plt.figure()
plt.subplot(211)
time_begin = 0
time_end = 10000

plt.plot(data.channels[0].time_index[time_begin:time_end], data.channels[0].data[time_begin:time_end],
         label='{} ({})'.format(data.channels[0].name, data.channels[0].units),
         alpha=0.7)
plt.plot(data.channels[1].time_index[time_begin:time_end], data.channels[1].data[time_begin:time_end],
         label='{} ({})'.format(data.channels[1].name, data.channels[1].units),
         alpha=0.7)
plt.plot(data.channels[2].time_index[time_begin:time_end], data.channels[2].data[time_begin:time_end],
         label='{} ({})'.format(data.channels[2].name, data.channels[2].units),
         alpha=0.5)
plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
           ncol=3, mode="expand", borderaxespad=0.)
plt.subplot(212)
plt.plot(data.channels[11].time_index[time_begin:time_end], data.channels[11].data[time_begin:time_end],
         label='{} ({})'.format(data.channels[11].name, data.channels[11].units),
         alpha=0.7)
plt.plot(data.channels[12].time_index[time_begin:time_end], data.channels[12].data[time_begin:time_end],
         label='{} ({})'.format(data.channels[12].name, data.channels[12].units),
         alpha=0.7)
plt.plot(data.channels[13].time_index[time_begin:time_end], data.channels[13].data[time_begin:time_end],
         label='{} ({})'.format(data.channels[13].name, data.channels[13].units),
         alpha=0.7)
plt.legend(bbox_to_anchor=(0., 1.02, 1., .102), loc=3,
           ncol=3, mode="expand", borderaxespad=0.)
fig.set_size_inches(10, 12)
plt.savefig('muscles_zoomed_in.png')

plt.show()