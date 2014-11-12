FactoryGirl.define do
  factory :vendor do
    name "first store"
    description "a store that sells disasters"
    street '101 Caramel Lane'
    city 'Raleigh'
    state 'NC'
    zip '27519'
    approved 'Yes'
    online 'Yes'
  end
end
