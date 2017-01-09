# Ways to transform functions so they can be used in a concatinative style

class Proc
   def trans(*args)
     newfunc =  ->(*a){
       bound = [a.size, args.size].min
       alist = (0...bound).collect{|i| a[args[i] ] }
       self.call(alist)
     }
   end
end

id = ->(*args){args.inspect}

f = id.trans(0,1,2)
p f.call(0,1,2) == "[[0, 1, 2]]"

g = id.trans(2,0,0)
p g.call() == "[[]]"
p g.call(0)  == "[[nil]]"
p g.call(0,1) == "[[nil, 0]]"
p g.call(0,1,2) == "[[2, 0, 0]]"
p g.call(0,1,2,3,4) == "[[2, 0, 0]]"








