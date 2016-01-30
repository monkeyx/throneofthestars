module Characters
  module Development
    def inheritable_traits
      self.traits.map{|trait| trait.category unless trait.cannot_inherit?}
    end

    def birth_chronum?
      self.birth_date.chronum == Game.current_date.chronum
    end

    def grow!
      if birth_chronum?
        become_child! if age == 7
        become_novice! if age == 14
        become_adult! if age == 18
      end
    end

    def mature!(add_skills = {})
      add_skills.each do |skill, rank|
        add_skill!(skill, rank)
      end
      become_child! if age >= 7
      become_novice! if age >= 14
      become_adult! if age >= 18
      if novice? || adult?
        update_attributes!(:action_points => 10)
      end
    end

    def born!
      if self.father
        if self.mother
          if male?
            add_news!("BORN_BOY","#{self.mother.display_name} and #{self.father.display_name}",false,false,self.birth_date)  
          else
            add_news!("BORN_GIRL","#{self.mother.display_name} and #{self.father.display_name}",false,false,self.birth_date)
          end
        else
          add_news!("BORN",self.father,false,false,self.birth_date)
        end
      end
    end

    def become_child!
      if self.mother.nil? && !(self.father.nil?) # seed characters do not have fathers or mothers but not bastards
        add_trait!(Trait::SPECIAL_BASTARD)
      elsif self.father && self.mother && self.father.related?(self.mother)
        add_trait!(Trait::SPECIAL_INBRED)
      else
        r = "1d100".roll
        if r > 99
          add_trait!(Trait::DISABILITIES.sample)
        elsif r > 73
          add_trait!(Trait::VICES.sample)
        elsif r > 52
          add_trait!(Trait::VIRTUES.sample)
        elsif r > 26
          if self.mother
            add_trait!(self.mother.inheritable_traits.sample)
          else
            add_trait!(Trait::VIRTUES.sample)
          end
        else
          if self.father
            add_trait!(self.father.inheritable_traits.sample)
          else
            add_trait!(Trait::VIRTUES.sample)
          end
        end
      end
    end

    def become_novice!
      if male?
        add_news!("NOVICE_BOY",nil,false,false,(self.birth_date + 140))
      else
        add_news!("NOVICE_GIRL",nil,false,false,(self.birth_date + 140))
      end
    end

    def become_adult!
      if self.bastard?
        r = "1d100".roll
        if r > 99
          add_trait!(Trait::MENTAL_HEALTH.sample)
        elsif r > 50
          add_trait!(Trait::VIRTUES.sample)
        elsif r > 25
          unless self.father
            # only seed characters may not have a father
            add_trait!(Trait::VICES.sample)
          else
            add_trait!(self.father.inheritable_traits.sample)
          end
        else
          add_trait!(Trait::VICES.sample)
        end
      elsif self.inbred?
        r = "1d100".roll
        if r > 90
          add_trait!(Trait::MENTAL_HEALTH.sample)
        elsif r > 50
          add_trait!(Trait::DISABILITIES.sample)
        elsif r > 25
          add_trait!(self.father.inheritable_traits.sample)
        else
          add_trait!(self.mother.inheritable_traits.sample)
        end
      else
        r = "1d100".roll
        if r > 99
          add_trait!(Trait::MENTAL_HEALTH.sample)
        elsif r > 50
          add_trait!(Trait::VIRTUES.sample)
        else
          add_trait!(Trait::VICES.sample)
        end
      end
      if self.skills.size < 1
        if squire?
          add_skill!(Skill::MILITARY_SKILLS.sample)
        elsif ward?
          add_skill!((Skill::MILITARY_SKILLS + Skill::CIVIL_SKILLS).sample)
        elsif lady_in_waiting?
          add_skill!((Skill::CIVIL_SKILLS + Skill::CHURCH_SKILLS).sample)
        elsif ensign?
          add_skill!(Skill::NAVAL_SKILLS.sample)
        else "2 in 1d6".chance.success?
          add_skill!(Skill::SKILL_TYPES.sample)
        end
      end
      self.apprenticeship.complete! if self.apprenticeship
      Apprentice.expire_apprenticeship_offers!(self)
      add_news!("ADULT",nil,false,false,(self.birth_date + 180))
    end
    
    def do_birthday!
      return unless birth_chronum?
      honour_total = 0
      glory_total = 0
      piety_total = 0
      self.titles.each do |title|
        honour_total += title.yearly_honour
        glory_total += title.yearly_glory
        piety_total += title.yearly_piety
      end
      if adult? && single? && !church?
        if male?
          honour_total -= 1
        else
          piety_total -= 1
        end
      end
      honour_total = add_honour!(honour_total).to_i
      glory_total = add_glory!(glory_total).to_i
      piety_total = add_piety!(piety_total).to_i
      blurb = []
      if honour_total > 0
        blurb << "gained #{honour_total} honour"
      elsif honour_total < 0
        blurb << "suffered a shaming loss of #{honour_total.abs} honour"
      end
      if glory_total > 0
        blurb << "gained #{glory_total} glory"
      elsif glory_total < 0
        blurb << "was weakened by a loss of #{glory_total.abs} glory"
      end
      if piety_total > 0
        blurb << "gained #{piety_total} piety"
      elsif piety_total < 0
        blurb << "was condemned with a loss of #{piety_total.abs} piety"
      end
      if blurb.size > 0
        add_news!("BIRTHDAY", " and " + (male? ? "his" : "her") + " House " + blurb.join(" and "))
      else
        add_news!("BIRTHDAY",'')
      end
    end
  end
end
