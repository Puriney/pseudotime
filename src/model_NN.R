mx.set.seed(2016)


## Network computation graph
num_fc1 <- 20 ## arbitrary number
num_softmax <- length(hr_int) ## should be equal to hr size

##
## To-do
## Gene nodes should be grouped based on GO clusters. This is good because:
## - biological meanings
## - reduce computating complexity


model_data <- mx.symbol.Variable('data')
model_hid1 <- mx.symbol.FullyConnected(model_data, name = 'fc1',
                                       num_hidden = num_fc1)
model_act1 <- mx.symbol.Activation(model_hid1, name = 'relu1',
                                   act_type = 'relu')
model_hid2 <- mx.symbol.FullyConnected(model_act1, name = 'fc2',
                                       num_hidden = num_softmax)
model <- mx.symbol.Softmax(model_FC1, name = 'softmax')
