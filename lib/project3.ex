[numNodes, numRequests] = System.argv()
numNodes = elem(Integer.parse(numNodes),0)
numRequests = elem(Integer.parse(numRequests),0)
Master.main(numNodes,numRequests)
