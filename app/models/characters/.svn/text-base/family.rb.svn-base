module Characters
  module Family
    def children(male=true,female=true)
      if male && female
        list = Character.children(self).living
      elsif male
        list = Character.children(self).living.male
      elsif female
        list = Character.children(self).living.female
      end
      list.sort!{|a,b|b.age <=> a.age}
    end

    def siblings(male=true,female=true)
      return [] unless self.father
      if male && female
        list = Character.siblings(self).living
      elsif male
        list = Character.siblings(self).living.male
      elsif female
        list = Character.siblings(self).living.female
      end
      list.sort!{|a,b|b.age <=> a.age}
    end

    def nephews
      list = []
      siblings.each do |sibling|
        list = list + sibling.children(true,false)
      end
      list.sort!{|a,b|b.age <=> a.age}
    end

    def nieces
      list = []
      siblings.each do |sibling|
        list = list + sibling.children(false,true)
      end
      list.sort!{|a,b|b.age <=> a.age}
    end

    def uncles(father_only=true)
      list = []
      list = list + father.siblings(true, false) if father
      list = list + mother.siblings(true, false) if mother && !father_only
      list.sort!{|a,b|b.age <=> a.age}
    end

    def aunts(father_only=true)
      list = []
      list = list + father.siblings(false, true) if father
      list = list + mother.siblings(false, true) if mother && !father_only
      list.sort!{|a,b|b.age <=> a.age}
    end


    def is_child?(other_character)
      return false unless other_character
      self.children(true, true).each{|child| return true if child.id == other_character.id}
      false
    end

    def is_sibling?(other_character)
      return false unless other_character
      self.siblings(true, true).each{|sibling| return true if sibling.id == other_character.id}
      false
    end

    def is_niece?(other_character)
      return false unless other_character
      self.nieces.each{|niece| return true if niece.id == other_character.id}
      false
    end

    def is_nephew?(other_character)
      return false unless other_character
      self.nephews.each{|nephew| return true if nephew.id == other_character.id}
      false
    end

    def is_cousin?(other_character)
      return false unless other_character
      self.uncles(false).each{|uncle| return true if other_character.is_child?(uncle)}
      self.aunts(false).each{|aunts| return true if other_character.is_child?(aunts)}
      false
    end

    def related?(other_character)
      return false if other_character.nil?
      return false unless self.father || other_character.father
      return true if self.father_id == other_character.id || self.mother_id == other_character.id
      return true if is_child?(other_character)
      return true if is_sibling?(other_character)
      return true if is_niece?(other_character)
      return true if is_nephew?(other_character)
      return true if is_cousin?(other_character)
      false
    end

    def relationship(other_character)
      return '' unless other_character
      return "Father" if self.father_id == other_character.id
      return "Mother" if self.mother_id == other_character.id
      return "Child" if is_child?(other_character)
      return "Sibling" if is_sibling?(other_character)
      return "Niece" if is_niece?(other_character)
      return "Nephew" if is_nephew?(other_character)
      return "Cousin" if is_cousin?(other_character)
      return "Liege" if self.liege && self.liege.id == other_character.id
      return "Vassal" if other_character.liege && other_character.liege.id == self.id
      return ""
    end

    def rightful_heir
      # oldest son
      list = children(true, false)
      list.each{|c| return c unless !c.can_inherit?}
      # oldest brother
      list = siblings(true, false)
      list.each{|c| return c unless !c.can_inherit?}
      # oldest nephew
      list = nephews
      list.each{|c| return c unless !c.can_inherit?}
      # father
      return self.father if father && father.alive? && father.can_inherit?
      # oldest uncle
      list = uncles
      list.each{|c| return c unless !c.can_inherit?}
      # oldest daughter
      list = children(false, true)
      list.each{|c| return c unless !c.can_inherit?}
      # oldest sister
      list = siblings(false, true)
      list.each{|c| return c unless !c.can_inherit?}
      # oldest niece
      list = nieces
      list.each{|c| return c unless !c.can_inherit?}
      # mother
      return mother if mother && mother.alive? && mother.can_inherit?
      # aunt
      list = aunts
      list.each{|c| return c unless !c.can_inherit?}
      # liege
      return liege if liege && liege.alive? && liege.can_inherit?
      # emperor (if there is one)
      emperor
    end
  end
end

