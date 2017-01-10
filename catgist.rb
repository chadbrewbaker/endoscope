# Ways to transform functions so they can be used in a concatinative style
class Proc
   def trans(*args)
       ->(*a){
           a.flatten!
           bound = [a.size, args.size].min
           alist = (0...bound).collect{|i| a[args[i] ] }
           self.call(alist)
       }
   end
   
   def lens(*args)
       concretes = [Integer,TrueClass,FalseClass,String,Float,Symbol,Array,Hash]
       ->(*a){
           a.flatten!
           bound = [a.size, args.size].min
           alist = (0...bound).collect{|i|
               if(concretes.include?(args[i].class))
                  args[i]
                else
                   args[i].call(a[i])
               end
           }
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

single = ->(a){a}
double = ->(a){a+a}
tripple = ->(a){a+a+a}
q = id.lens(single, double,tripple)
p q.call(5,5,5) == "[[5, 10, 15]]"
p q.call(1,2,3) == "[[1, 4, 9]]"

h = q.lens(single,double,tripple)
p h.call(5,5,5) == "[[5, 20, 45]]"
k = id.lens(single, 444,tripple)
p k.call(4,4,4,4,4) == "[[4, 444, 12]]"





