<template>
  <div>
    <answer-form
      v-if="isPlayer"
      :problem-body="problemBody"
      :latest-answer="sortedAnswers[0]"
      class="mb-1"
    />

    <answer-card
      v-for="answer in sortedAnswers"
      :key="answer.id"
      :answer="answer"
      :problem-body="problemBody"
      class="mb-1"
    />
  </div>
</template>
<script>
import AnswerCard from '~/components/problems/id/AnswerCard'
import AnswerForm from '~/components/problems/id/AnswerForm'
export default {
  name: 'AnswerPanel',
  components: {
    AnswerCard,
    AnswerForm
  },
  props: {
    answers: {
      type: Array,
      required: true
    },
    problemBody: {
      type: Object,
      required: true
    }
  },
  computed: {
    sortedAnswers() {
      return this.sortByCreatedAt(this.answers).reverse()
    }
  }
}
</script>
